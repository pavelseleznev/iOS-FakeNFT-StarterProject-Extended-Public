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
	private(set) var nfts = [String : NFTModelContainer?]()
	private var sortedKeys = [String]()
	private(set) var isLoaded = false
	private(set) var filteredKeys = [String]()
	
	private var nftsLoadTask: Task<Void, Never>?
	private var loadingTask: Task<Void, Never>?
	
	private(set) var removalApproveAlertIsPresented = false
	private(set) var modelForRemoval: NFTModelContainer?
	var dataLoadingErrorIsPresented = false
	var searchText = ""
	
	private let nftService: NFTServiceProtocol
	private let cartService: CartServiceProtocol
	let onSubmmit: () -> Void
	
	private let cartPingInterval: Duration = .seconds(5)
	
	init(
		nftService: NFTServiceProtocol,
		cartService: CartServiceProtocol,
		onSubmit: @escaping () -> Void,
	) {
		self.nftService = nftService
		self.cartService = cartService
		self.onSubmmit = onSubmit
	}
}

// MARK: - CartViewModel Extensions
// --- internal helpers ---
extension CartViewModel {
	func onDebounce(_ searchText: String) {
		self.searchText = searchText
		
		if isLoaded {
			applyFilter()
		}
	}
	
	func setSortOption(_: SortOption, _ option: SortOption) {
		HapticPerfromer.shared.play(.impact(.light))
		sortOption = option
		
		if isLoaded {
			applySort()
		}
	}
	
	func viewDidDissappear() {
		clearNftsLoadTask()
	}
	
	func performCartUpdateIfNeeded(with ids: [String] = []) async {
		let newCartIDs: Set<String>
		if ids.isEmpty {
			newCartIDs = await cartService.getCart()
		} else {
			newCartIDs = Set(ids)
		}
		
		let oldIDs = Set(nfts.keys)
		guard oldIDs != newCartIDs else { return }
		
		let idsToRemove = oldIDs.subtracting(Set(newCartIDs))
		let idsToAdd = newCartIDs.subtracting(oldIDs)
		
		var anyChange = false
		if !idsToRemove.isEmpty {
			anyChange = true
			idsToRemove.forEach { nfts.removeValue(forKey: $0) }
			sortedKeys.removeAll(where: { idsToRemove.contains($0) })
			filteredKeys.removeAll(where: { idsToRemove.contains($0) })
		}
		
		if !idsToAdd.isEmpty {
			anyChange = true
			nfts.reserveCapacity(nfts.count + idsToAdd.count)
			idsToAdd.forEach {
				nfts.updateValue(.none, forKey: $0)
				if !sortedKeys.contains($0) {
					sortedKeys.append($0)
				}
				if !filteredKeys.contains($0) {
					filteredKeys.append($0)
				}
			}
		}
		
		if anyChange {
			HapticPerfromer.shared.play(.selection)
		}
		
		loadNilNFTsIfNeeded()
	}
	
	func update(with notification: Notification) {
		guard let ids = notification.userInfo?[NFTsIDsKind.order.userDefaultsKey] as? [String] else { return }
		
		Task {
			await performCartUpdateIfNeeded(with: ids)
		}
	}

	func loadNilNFTsIfNeeded() {
		let unloaded = nfts.filter(\.value.isNil).map(\.key)
		
		guard !unloaded.isEmpty else {
			if !sortedKeys.isEmpty && !isLoaded {
				applySort()
				isLoaded = true
			}
			return
		}
		
		let chunks = unloaded.chunked(into: 6)
		
		loadingTask?.cancel()
		loadingTask = Task {
			for chunk in chunks {
				guard !Task.isCancelled else { return }
				
				let results = await withTaskGroup(
					of: NFTResponse?.self,
					returning: [NFTResponse].self
				) { group in
					
					for id in chunk {
						group.addTask { [weak self] in
							guard !Task.isCancelled else { return nil }
							return try? await self?.nftService.loadNFT(id: id)
						}
					}
					
					var collected = [NFTResponse]()
					for await nft in group {
						if let nft {
							collected.append(nft)
						}
					}
					
					return collected
				}
				
				for nft in results {
					nfts.updateValue(
						.init(
							nft: nft,
							isFavorite: false,
							isInCart: true
						),
						forKey: nft.id
					)
				}
			}
			
			guard !Task.isCancelled else { return }
			
			let failedCount = nfts.filter(\.value.isNil).count
			if failedCount > 0 {
				dataLoadingErrorIsPresented = true
			} else {
				applySort()
				isLoaded = true
			}
		}
	}
	
	func startLoadNilNFTsBackgroundPolling() {
		guard nftsLoadTask.isNil else { return }
		
		let task = Task(priority: .utility) {
			defer { clearNftsLoadTask() }
			while !Task.isCancelled {
				do {
					if isLoaded {
						loadNilNFTsIfNeeded()
					}
					try await waitPolling()
				} catch is CancellationError {
					print("\nCartViewModel \(#function) cancelled")
					break
				} catch {
					print("\nCartViewModel \(#function) caught unexpected error: \(error.localizedDescription)")
				}
			}
		}
		
		nftsLoadTask = task
	}
	
	func reloadCart() {
		startLoadNilNFTsBackgroundPolling()
	}
}

// --- appliers ---
private extension CartViewModel {
	func applyFilter() {
		filteredKeys = sortedKeys
			.filter {
				guard !searchText.isEmpty else { return true }
				guard let item = nfts[$0] ?? nil else { return false }
				return item.nft.name.localizedStandardContains(searchText)
			}
	}
	
	func applySort() {
		sortedKeys
			.sort { lhsKey, rhsKey in
				guard
					let lhs = nfts[lhsKey] ?? nil,
					let rhs = nfts[rhsKey] ?? nil
				else {
					return false
				}
				
				return sortComparator(lhs, rhs)
			}
		
		filteredKeys = sortedKeys
	}
}

// --- private helpers ---
private extension CartViewModel {
	func sortComparator(_ lhs: NFTModelContainer?, _ rhs: NFTModelContainer?) -> Bool {
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
	
	func waitPolling() async throws {
		try await Task.sleep(for: cartPingInterval)
	}
	
	func onError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		
		HapticPerfromer.shared.play(.notification(.error))
		
		withAnimation(Constants.defaultAnimation) {
			dataLoadingErrorIsPresented = true
		}
	}
	
	func clearNftsLoadTask() {
		nftsLoadTask?.cancel()
		nftsLoadTask = nil
		
		loadingTask?.cancel()
		loadingTask = nil
	}
}

// --- data getters ---
extension CartViewModel {
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
		
		filteredKeys.removeAll(where: { $0 == modelForRemoval.id })
		sortedKeys.removeAll(where: { $0 == modelForRemoval.id })
		nfts.removeValue(forKey: modelForRemoval.id)
		Task(priority: .userInitiated) {
			try await nftService.removeFromCart(nftID: modelForRemoval.id)
		}
	}
}
