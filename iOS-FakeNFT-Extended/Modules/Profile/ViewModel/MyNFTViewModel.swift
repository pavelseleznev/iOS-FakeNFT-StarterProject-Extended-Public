//
//  MyNFTViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/19/25.
//

import SwiftUI

@MainActor
@Observable
final class MyNFTViewModel {
	var loadErrorPresented = false
    var loadErrorMessage: LocalizedStringResource = .addToFavoriteError
    var myNFTs: LocalizedStringResource = .myNFTs
	private(set) var isLoaded = false
	private(set) var isLoading = false
	private(set) var filteredKeys = [String]()
	private(set) var _kickUIUpdate = false
	
	@ObservationIgnored private(set) var sortOption: ProfileSortActionsViewModifier.SortOption = .name
	@ObservationIgnored private var loadingTask: Task<Void, Never>?
	
	@ObservationIgnored private let loadNFT: @Sendable (String) async throws -> NFTResponse
	@ObservationIgnored private let loadPurchasedNFTs: @Sendable () async -> Set<String>
	@ObservationIgnored private let favouritesService: NFTsIDsServiceProtocol
	
	@ObservationIgnored private(set) var items = [String : NFTModelContainer?]()
	@ObservationIgnored private var sortedKeys = [String]()
	@ObservationIgnored private var _updateID = UUID()
	@ObservationIgnored private var searchText = ""
    
	init(
		favouritesService: NFTsIDsServiceProtocol,
		loadNFT: @escaping @Sendable (String) async throws -> NFTResponse,
		loadPurchasedNFTs: @escaping @Sendable () async -> Set<String>,
		initialNFTsIDs: Set<String>
	) {
        self.favouritesService = favouritesService
		self.loadNFT = loadNFT
		self.loadPurchasedNFTs = loadPurchasedNFTs
		
		initialNFTsIDs.forEach {
			items.updateValue(.none, forKey: $0)
			sortedKeys.append($0)
			filteredKeys.append($0)
		}
		
		loadNilNFTsIfNeeded()
    }
}

// MARK: - MyNFTViewModel Extensions
// --- appliers ---
private extension MyNFTViewModel {
	func applyFilter() {
		filteredKeys = sortedKeys
			.filter {
				guard !searchText.isEmpty else { return true }
				guard let item = items[$0] ?? nil else { return false }
				return item.nft.name.localizedStandardContains(searchText)
			}
	}
	
	func applySort() {
		sortedKeys
			.sort { lhsKey, rhsKey in
				guard
					let lhs = items[lhsKey] ?? nil,
					let rhs = items[rhsKey] ?? nil
				else {
					return false
				}
				
				return itemsSortComparator(lhs, rhs)
			}
		
		filteredKeys = sortedKeys
	}
}

// --- handlers ---
extension MyNFTViewModel {
	func purchasedDidUpdate(_ notification: Notification) {
		guard
			let ids = notification.userInfo?[NFTsIDsKind.purchased.userDefaultsKey] as? [String]
		else { return }
		
		performUpdate(newIDs: ids)
	}
	
	func didTapLikeButton(_ model: NFTModelContainer?) {
		guard let model else { return }
		
		isLoading = true
		defer { isLoading = false }
		
		Task {
			do {
				if await favouritesService.contains(model.id) {
					try await favouritesService.remove(model.id)
				} else {
					try await favouritesService.add(model.id)
				}
				
				items[model.id] = .init(
					nft: model.nft,
					isFavorite: !model.isFavorite,
					isInCart: false
				)
				
				_kickUIUpdate.toggle()
				
			} catch is CancellationError {
				return
			} catch {
                loadErrorMessage = .addToFavoriteError
				loadErrorPresented = true
			}
		}
	}
}

// --- helpers ---
private extension MyNFTViewModel {
	func performUpdate<T: Collection<String>>(newIDs: T) {
		let ids = Set(newIDs)
		let oldIDs = Set(items.keys)
		
		guard ids != oldIDs else { return }
		
		isLoaded = false
		
		let newIDs = ids.subtracting(oldIDs)
		let idsToRemove = oldIDs.subtracting(ids)
		
		if !idsToRemove.isEmpty {
			idsToRemove.forEach { items.removeValue(forKey: $0) }
			sortedKeys.removeAll(where: { idsToRemove.contains($0) })
		}
		
		if !newIDs.isEmpty {
			items.reserveCapacity(items.count + newIDs.count)
			newIDs.forEach {
				items.updateValue(.none, forKey: $0)
				sortedKeys.append($0)
			}
		}
		
		loadNilNFTsIfNeeded()
	}
}

// --- loaders ---
extension MyNFTViewModel {
	func loadPurchasedNFTs() async {
		let ids = await loadPurchasedNFTs()
		guard ids != Set(sortedKeys) else { return }
		
		performUpdate(newIDs: ids)
	}
	
	func loadNilNFTsIfNeeded() {
		let unloaded = items.filter(\.value.isNil).map(\.key)
		
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
							return try? await self?.loadNFT(id)
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
					items[nft.id] = .init(
						nft: nft,
						isFavorite: await favouritesService.contains(nft.id),
						isInCart: false
					)
				}
			}
			
			guard !Task.isCancelled else { return }
			
			let failedCount = items.filter(\.value.isNil).count
			if failedCount > 0 {
				loadErrorPresented = true
			} else {
				applySort()
			}
			
			isLoaded = true
		}
	}
}

// --- helpers ---
extension MyNFTViewModel {
	private func itemsSortComparator(
		_ first: NFTModelContainer,
		_ second: NFTModelContainer
	) -> Bool {
		switch sortOption {
		case .name:
			first.nft.name.localizedCaseInsensitiveCompare(second.nft.name) == .orderedAscending
		case .cost:
			first.nft.price < second.nft.price
		case .rate:
			first.nft.rating > second.nft.rating
		}
	}
	
	func onDebounce(_ text: String) {
		searchText = text
		applyFilter()
	}
	
	func setSortOption(_ option: ProfileSortActionsViewModifier.SortOption) {
		guard option != sortOption else { return }
		sortOption = option
		
		if isLoaded {
			applySort()
		}
	}
}
