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
	
	private let nftService: NFTServiceProtocol
	private let push: (Page) -> Void
	
	private let cartPingInterval: Duration = .seconds(1)
	
	init(
		nftService: NFTServiceProtocol,
		push: @escaping (Page) -> Void,
	) {
		self.nftService = nftService
		self.push = push
	}
}

// MARK: - CartViewModel Extensions
// --- internal helpers ---
extension CartViewModel {
	func setSortOption(_ option: SortOption) {
		sortOption = option
	}
	
	private func waitPolling() async throws {
		try await Task.sleep(for: cartPingInterval)
	}
	
	private func onError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(.easeInOut(duration: 0.15)) {
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
	
	func updateIDs() async {
		if let idsUpdateTask {
			await idsUpdateTask.value
			return
		}
		
		let task = Task(priority: .background) {
			defer { clearIdsUpdateTask() }
			while !Task.isCancelled {
				do {
					try Task.checkCancellation()
					let ids = await nftService.getAllCart()
					
					let currentIds = Array(nfts.keys)
					let diff = difference(currentIds, ids)
					
					guard !diff.onlyInFirst.isEmpty || !diff.onlyInSecond.isEmpty else {
						try await waitPolling()
						continue
					}
					
					await MainActor.run {
						diff.onlyInFirst.forEach {
							nfts.removeValue(forKey: $0)
						}
						
						nfts.reserveCapacity(nfts.count + diff.onlyInSecond.count)
						diff.onlyInSecond.forEach {
							nfts[$0, default: nil] = nil
						}
					}
					
					try await waitPolling()
				} catch {
					onError(error)
					break
				}
			}
		}
		
		idsUpdateTask = task
		await task.value
	}
	
	func loadNilNFTs() async {
		if let nftsLoadTask {
			await nftsLoadTask.value
			return
		}
		
		let task = Task(priority: .background) {
			defer { clearNftsLoadTask() }
			while !Task.isCancelled {
				do {
					try Task.checkCancellation()
					let ids = notLoadedIDs
					if !ids.isEmpty {
						try await loadNFTs(using: ids)
					}
					
					try await waitPolling()
				} catch {
					onError(error)
					break
				}
			}
		}
		
		nftsLoadTask = task
		await task.value
	}
	
	func reloadCart() {
		Task {
			if idsUpdateTask == nil {
				await updateIDs()
			}
		}
		
		Task {
			if nftsLoadTask == nil {
				await loadNilNFTs()
			}
		}
	}
	
	private func loadNFTs(using ids: [String]) async throws {
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
	
	func performPayment() {
		push(.paymentMethodChoose)
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
				.sorted {
					guard let first = $0, let second = $1 else { return false }
					switch sortOption {
					case .name:
						return first.nft.name.localizedStandardCompare(second.nft.name) == .orderedAscending
					case .cost:
						return first.nft.price.isLess(than: second.nft.price)
					case .rate:
						return first.nft.rating < second.nft.rating
					}
				}
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
		return String(
			format: "%0.2f",
			isGreaterThanThousand ? cartCost / 1000 : cartCost
		) +
		(isGreaterThanThousand ? "K" : "") +
		" ETH"
	}
}

// --- nft removal actions ---
extension CartViewModel {
	func setNFTForRemoval(_ nft: NFTModelContainer?) {
		withAnimation(.easeInOut(duration: 0.15)) {
			modelForRemoval = nft
			removalApproveAlertIsPresented = true
		}
	}
	
	func nftDismissAction() {
		withAnimation(.easeInOut(duration: 0.15)) {
			modelForRemoval = nil
			removalApproveAlertIsPresented = false
		}
	}
	
	func removeNFTFromCart() {
		guard let modelForRemoval else { return }
		
		Task { @Sendable in
			await nftService.removeFromCart(id: modelForRemoval.id)
			nfts.removeValue(forKey: modelForRemoval.id)
		}
	}
}

// MARK: - Private helpers
private struct ArrayDifference<T: Hashable> {
	let onlyInFirst: [T]
	let onlyInSecond: [T]
}

private func difference<T: Hashable>(_ array1: [T], _ array2: [T]) -> ArrayDifference<T> {
	let set1 = Set(array1)
	let set2 = Set(array2)

	return ArrayDifference(
		onlyInFirst: Array(set1.subtracting(set2)),
		onlyInSecond: Array(set2.subtracting(set1))
	)
}
