//
//  FavoriteNFTViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/23/25.
//

import SwiftUI

@MainActor
@Observable
final class FavoriteNFTViewModel {
	private(set) var filteredKeys = [String]()
	@ObservationIgnored private var sortedKeys = [String]()
	private(set) var items = [String : NFTResponse?]()
	private(set) var isLoading = false
	
    var loadErrorPresented = false
    var removeFavoriteErrorMessage: LocalizedStringResource = .removeFavoriteErrorMessage
    var favouritedNFTs: LocalizedStringResource = .favouritedNFTs
    
	@ObservationIgnored private let service: NFTServiceProtocol
	@ObservationIgnored private var loadingTask: Task<Void, Never>?
	@ObservationIgnored private var searchText = ""
    
	init(service: NFTServiceProtocol, initialNFTsIDs: Set<String>) {
		self.service = service
		
		initialNFTsIDs.forEach {
			sortedKeys.append($0)
			filteredKeys.append($0)
			items.updateValue(.none, forKey: $0)
		}
		
		loadNilNFTsIfNeeded()
    }
}

// MARK: - FavoriteNFTViewModel Extensions
// --- appliers ---
private extension FavoriteNFTViewModel {
	func applyFilter() {
		filteredKeys = sortedKeys
			.filter {
				guard !searchText.isEmpty else { return true }
				guard let item = items[$0] ?? nil else { return false }
				return item.name.localizedStandardContains(searchText)
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
				
				return lhs.id.localizedStandardCompare(rhs.id) == .orderedAscending
			}
		
		applyFilter()
	}
}

// --- helpers ---
extension FavoriteNFTViewModel {
	func favouritesDidUpdate(_ notification: Notification) {
		guard
			let _ids = notification.userInfo?[NFTsIDsKind.favorites.userDefaultsKey] as? [String]
		else { return }
		
		let ids = Set(_ids)
		let oldIDs = Set(items.keys)
		
		guard ids != oldIDs else { return }
		
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
			
			sortedKeys.sort { $0.localizedStandardCompare($1) == .orderedAscending }
		}
		
		loadNilNFTsIfNeeded()
	}
	
	func removeFromFavorites(id: String) async {
		isLoading = true
		defer { isLoading = false }
		do {
			try await service.removeFromFavourites(nftID: id)
			filteredKeys.removeAll { $0 == id }
			sortedKeys.removeAll { $0 == id }
			items.removeValue(forKey: id)
		} catch is CancellationError {
			return
		} catch {
			loadErrorPresented = true
		}
	}
	
	func onDebounce(_ text: String) {
		searchText = text
		applyFilter()
	}
	
	func didTapLikeButton(for model: NFTResponse?) {
		guard let id = model?.id else { return }
		
		Task {
			await removeFromFavorites(id: id)
		}
	}
}

// --- loaders ---
extension FavoriteNFTViewModel {
	func loadFavorites() async {
		let ids = await service.favouritesService.get().sorted {
			$0.localizedStandardCompare($1) == .orderedAscending
		}
		
		guard Set(ids) != Set(sortedKeys) else { return }
		sortedKeys = ids
		ids.forEach { items.updateValue(.none, forKey: $0) }
		
		loadNilNFTsIfNeeded()
	}
	
	func loadNilNFTsIfNeeded() {
		let unloaded = items.filter(\.value.isNil).map(\.key)
		guard !unloaded.isEmpty else { return }
		
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
							return try? await self?.service.loadNFT(id: id)
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
				
				results.forEach { items[$0.id] = $0 }
			}
			
			guard !Task.isCancelled else { return }
			
			let failedCount = items.filter(\.value.isNil).count
			if failedCount > 0 {
				loadErrorPresented = true
			} else {
				withAnimation(nil) {
					applySort()
				}
			}
		}
	}
}
