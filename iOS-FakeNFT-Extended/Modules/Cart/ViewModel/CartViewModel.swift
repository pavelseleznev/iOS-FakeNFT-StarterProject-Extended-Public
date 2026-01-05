//
//  CartViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

@Observable
@MainActor
final class CartViewModel {
	typealias SortOption = CartSortActionsViewModifier.SortOption
	
	private var sortOption: SortOption = .cost
	private var nfts = [String : NFTModelContainer?]()

	private var idsUpdateTask: Task<Void, Never>?
	private var nftsLoadTask: Task<Void, Never>?
	
	private(set) var removalApproveAlertIsPresented = false
	private(set) var modelForRemoval: NFTModelContainer?
	var dataLoadingErrorIsPresented = false
	var searchText = ""
	
	private let nftService: NFTServiceProtocol
	private let cartService: CartServiceProtocol
	private let push: (Page) -> Void
	
	private let cartPingInterval: Duration = .seconds(5)
	
	init(
		nftService: NFTServiceProtocol,
		cartService: CartServiceProtocol,
		push: @escaping (Page) -> Void,
	) {
		self.nftService = nftService
		self.cartService = cartService
		self.push = push
	}
}

// MARK: - CartViewModel Extensions
// --- internal helpers ---
extension CartViewModel {
	func onDebounce(_ searchText: String) {
		self.searchText = searchText
	}
	
	func setSortOption(_: SortOption, _ option: SortOption) {
		sortOption = option
	}
	
	func viewDidDissappear() {
		clearIdsUpdateTask()
		clearNftsLoadTask()
	}
	
	func updateIDs(isPolling: Bool) async {
		do {
			try Task.checkCancellation()
			let loadedIDs = await cartService.getCart()
			
			let oldIDs = Set(nfts.keys)
			let newIDs = Set(loadedIDs).subtracting(oldIDs)
			let idsToRemove = oldIDs.subtracting(Set(loadedIDs))
			
			let newCapacity = oldIDs.count - idsToRemove.count + newIDs.count
			
			guard newCapacity != oldIDs.count else {
				if isPolling {
					try await waitPolling()
				}
				return
			}
			
			idsToRemove.forEach {
				nfts.removeValue(forKey: $0)
			}
			
			nfts.reserveCapacity(newCapacity)
			newIDs.forEach {
				nfts[$0, default: nil] = nil
			}
		} catch {
			onError(error)
		}
	}
	
	func startIDsUpdateBackgroundPolling() {
		guard idsUpdateTask.isNil else { return }
		
		let task = Task(priority: .utility) {
			defer { clearIdsUpdateTask() }
			while !Task.isCancelled {
				do {
					await updateIDs(isPolling: true)
					try await waitPolling()
				} catch is CancellationError {
					print("\n\(#function) cancelled")
					break
				} catch {
					print("\n\(#function) caught unexpected error: \(error.localizedDescription)")
				}
			}
		}
		
		idsUpdateTask = task
	}
	
	func loadNilNFTs() async {
		do {
			try Task.checkCancellation()
			let ids = notLoadedIDs
			if !ids.isEmpty {
				try await loadNFTs(using: ids)
			}
		} catch {
			onError(error)
		}
	}
	
	func startLoadNilNFTsBackgroundPolling() {
		guard nftsLoadTask.isNil else { return }
		
		let task = Task(priority: .utility) {
			defer { clearNftsLoadTask() }
			while !Task.isCancelled {
				do {
					await loadNilNFTs()
					try await waitPolling()
				} catch is CancellationError {
					print("\n\(#function) cancelled")
					break
				} catch {
					print("\n\(#function) caught unexpected error: \(error.localizedDescription)")
				}
			}
		}
		
		nftsLoadTask = task
	}
	
	func reloadCart() {
		startIDsUpdateBackgroundPolling()
		startLoadNilNFTsBackgroundPolling()
	}
	
	func performPayment() {
		push(.paymentMethodChoose)
	}
}

// --- private helpers ---
private extension CartViewModel {
	func sortComparator(lhs: NFTModelContainer?, rhs: NFTModelContainer?) -> Bool {
		guard let lhs, let rhs else { return false }
		
		switch sortOption {
		case .name:
			let lhsPriority = comparatorPriority(lhs.nft.name)
			let rhsPriority = comparatorPriority(rhs.nft.name)
			
			if lhsPriority != rhsPriority {
				return lhsPriority < rhsPriority
			}
			
			return lhs.nft.name.localizedStandardCompare(rhs.nft.name) == .orderedAscending
		case .cost:
			return lhs.nft.price.isLess(than: rhs.nft.price)
		case .rate:
			return lhs.nft.rating < rhs.nft.rating
		}
	}
	
	func filterApplier(_ model: NFTModelContainer?) -> Bool {
		if !searchText.isEmpty, let model {
			model.nft.name.localizedCaseInsensitiveContains(searchText)
		} else {
			true
		}
	}
	
	func waitPolling() async throws {
		try await Task.sleep(for: cartPingInterval)
	}
	
	func onError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(Constants.defaultAnimation) {
			dataLoadingErrorIsPresented = true
		}
	}
	
	func clearIdsUpdateTask() {
		idsUpdateTask?.cancel()
		idsUpdateTask = nil
	}
	
	func clearNftsLoadTask() {
		nftsLoadTask?.cancel()
		nftsLoadTask = nil
	}
	
	func loadNFTs(using ids: [String]) async throws {
		for id in ids {
			try Task.checkCancellation()
			let nft = try await nftService.loadNFT(id: id)
			nfts[id, default: nil] = .init(
				nft: nft,
				isFavorite: false,
				isInCart: true
			)
		}
	}
}

// --- data getters ---
extension CartViewModel {
	var isLoaded: Bool {
		nfts.compactMap(\.value).count == nfts.count
	}
	
	@inline(__always)
	private var notLoadedIDs: [String] {
		nfts.filter { $0.value == nil }.map(\.key)
	}
	
	var visibleNfts: [NFTModelContainer?] {
		if isLoaded {
			nfts
				.map(\.value)
				.sorted(by: sortComparator)
				.filter(filterApplier)
		} else {
			nfts
				.map(\.value)
				.map { _ in nil }
		}
	}
	
	var nftCount: Int {
		nfts.count
	}
	
	private var cartCost: Float {
		nfts.compactMap(\.value?.nft.price).reduce(0, +)
	}
	
	var cartCostLabel: String {
		let isGreaterThanThousand = cartCost > 1000
		let string = String(isGreaterThanThousand ? cartCost / 1000 : cartCost)
		if let double = Double(string) {
			return String(
				format: "%0.2f",
				double,
			) +
			(isGreaterThanThousand ? "K" : "") +
			" ETH"
		} else {
			return "0.00 ETH"
		}
	}
}

// --- nft removal actions ---
extension CartViewModel {
	func setNFTForRemoval(_ nft: NFTModelContainer?) {
		withAnimation(Constants.defaultAnimation) {
			modelForRemoval = nft
			removalApproveAlertIsPresented = true
		}
	}
	
	func nftDismissAction() {
		withAnimation(Constants.defaultAnimation) {
			modelForRemoval = nil
			removalApproveAlertIsPresented = false
		}
	}
	
	func removeNFTFromCart() {
		guard let modelForRemoval else { return }
		
		nfts.removeValue(forKey: modelForRemoval.id)
		Task(priority: .userInitiated) {
			try await nftService.removeFromCart(nftID: modelForRemoval.id)
		}
	}
}
