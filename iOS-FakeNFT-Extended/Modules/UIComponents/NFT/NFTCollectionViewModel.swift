//
//  NFTCollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 18.12.2025.
//

import SwiftUI

@MainActor
final class NFTCollectionViewModel: ObservableObject {
	@Published private(set) var isLoaded = false
	@Published private(set) var filteredKeys = [String]()
	@Published private var sortedKeys = [String]()
	@Published private(set) var nfts = [String : NFTModelContainer?]()
	private let loadAuthor: @Sendable (String) async throws -> UserListItemResponse
	private let loadCollection: @Sendable (String) async throws -> NFTCollectionItemResponse
	var errorIsPresented = false
	
	private var pollingTask: Task<Void, Never>?
	private var fetchingTask: Task<Void, Error>?
	
	var activeTokens = [FilterToken]()
	private var searchText: String = ""
	private var viewDidDisappeared = false
	private var updatesID: UUID?
	
	private let didTapDetail: (NFTModelContainer, [Dictionary<String, NFTModelContainer?>.Element]) -> Void
	private let nftService: NFTServiceProtocol
	private let pollingInterval: Duration = .seconds(5)
	private let collectionID: String?
	private let authorID: String?
	private let isFromCollection: Bool
	
	init(
		loadAuthor: @escaping @Sendable (String) async throws -> UserListItemResponse,
		loadCollection: @escaping @Sendable (String) async throws -> NFTCollectionItemResponse,
		nftService: NFTServiceProtocol,
		initialNFTsIDs: [String],
		isFromCollection: Bool,
		collectionID: String?,
		authorID: String?,
		didTapDetail: @escaping (NFTModelContainer, [Dictionary<String, NFTModelContainer?>.Element]) -> Void
	) {
		self.loadAuthor = loadAuthor
		self.loadCollection = loadCollection
		self.nftService = nftService
		self.isFromCollection = isFromCollection
		self.authorID = authorID
		self.collectionID = collectionID
		self.didTapDetail = didTapDetail
		
		initialNFTsIDs.forEach {
			nfts.updateValue(.none, forKey: $0)
			filteredKeys.append($0)
			sortedKeys.append($0)
		}
		
		applySort(isInitial: true)
		loadNilNFTsIfNeeded(isInitial: true)
	}
}

// MARK: - AsyncNFTs extensions

// --- internal helpers ---
extension NFTCollectionViewModel {
	func didTapDetailOnCell(_ nft: NFTModelContainer) {
		var shouldProceed = false
		
		if isFromCollection, let collectionID, !collectionID.isEmpty {
			shouldProceed = true
		}
		
		if !isFromCollection, let authorID, !authorID.isEmpty {
			shouldProceed = true
		}
		
		guard shouldProceed else { return }
		didTapDetail(nft, nfts.sorted { $0.key < $1.key })
	}
	
	func didTapLikeButton(for model: NFTModelContainer?, isFromNotification: Bool = false) {
		guard let model else { return }
		
		if !isFromNotification {
			HapticPerfromer.shared.play(.impact(.light))
		}
		
		switchLikeState(for: model, key: model.id)
		Task(priority: .userInitiated) {
			do {
				if await nftService.favouritesService.contains(model.id) {
					try await nftService.removeFromFavourites(nftID: model.id)
				} else {
					try await nftService.addToFavourites(nftID: model.id)
				}
			} catch {
				HapticPerfromer.shared.play(.notification(.error))
				print("failed to change like state: \(error.localizedDescription)")
			}
		}
	}
	
	func didTapCartButton(for model: NFTModelContainer?, isFromNotification: Bool = false) {
		guard let model else { return }
		
		if !isFromNotification {
			HapticPerfromer.shared.play(.impact(.light))
		}
		
		switchCartState(for: model, key: model.id)
		Task(priority: .userInitiated) {
			do {
				if await nftService.orderService.contains(model.id) {
					try await nftService.removeFromCart(nftID: model.id)
				} else {
					try await nftService.addToCart(nftID: model.id)
				}
			} catch {
				HapticPerfromer.shared.play(.notification(.error))
				print("failed to change cart state: \(error.localizedDescription)")
			}
		}
	}
	
	func viewDidDissappear() {
		viewDidDisappeared = true
		clearAllATasks()
	}
	
	func tokenAction(for token: FilterToken) {
		if activeTokens.contains(token.contrary) {
			activeTokens.removeAll(where: { $0 == token.contrary })
		}
		
		if activeTokens.contains(token) {
			activeTokens.removeAll(where: { $0 == token })
		} else {
			activeTokens.append(token)
		}
		
		applySort()
	}
	
	func onDebounce(_ text: String) {
		searchText = text
		
		if isLoaded {
			applyFilter()
		}
	}
}

// --- appliers ---
private extension NFTCollectionViewModel {
	func applyFilter() {
		filteredKeys = sortedKeys
			.filter(filterApplier)
	}
	
	func applySort(isInitial: Bool = false) {
		sortedKeys
			.sort { lhsKey, rhsKey in
				guard
					let lhs = nfts[lhsKey] ?? nil,
					let rhs = nfts[rhsKey] ?? nil
				else { return false }
				
				return sortComparator(lhs, rhs)
			}
		
		if !isInitial {
			applyFilter()
		} else {
			filteredKeys = sortedKeys
		}
	}
}

// --- private helpers ---
extension NFTCollectionViewModel {
	func handleNFTChangeNotification(notification: Notification) {
		guard
			let payload = notification.userInfo?[Constants.nftChangePayloadKey] as? NFTUpdatePayload,
			updatesID != payload.updatesID,
			let model = nfts[payload.id] ?? nil,
			payload.hasChanges
		else { return }
		
		updatesID = payload.updatesID
		
		if payload.isCartChanged {
			didTapCartButton(for: model, isFromNotification: true)
		}
		
		if payload.isFavoriteChanged {
			didTapLikeButton(for: model, isFromNotification: true)
		}
	}
	
	func sortComparator(
		_ model1: NFTModelContainer,
		_ model2: NFTModelContainer
	) -> Bool {
		let activeSortOptions = activeTokens.filter(\.isSortOption)
		guard !activeSortOptions.isEmpty else {
			return model1.id.localizedStandardCompare(model2.id) == .orderedAscending
		}
		
		return activeSortOptions.allSatisfy { sortOption in
			switch sortOption {
			case .ratingAscending:
				return model1.nft.rating < model2.nft.rating
			case .ratingDescending:
				return model1.nft.rating > model2.nft.rating
			case .costAscending:
				return model1.nft.price < model2.nft.price
			case .costDescending:
				return model1.nft.price > model2.nft.price
			default:
				return false
			}
		}
	}
	
	func filterApplier(_ id: String) -> Bool {
		guard let item = nfts[id] ?? nil else { return true }
		
		let matchesText = searchText.isEmpty ||
			item.nft.name.localizedCaseInsensitiveContains(searchText)
		
		let matchesTokens = activeTokens.allSatisfy { token in
			switch token {
			case .isFavourite:
				item.isFavorite
			case .isInCart:
				item.isInCart
			case .isNotFavourite:
				!item.isFavorite
			case .isNotInCart:
				!item.isInCart
			default:
				true
			}
		}
		
		return matchesText && matchesTokens
	}
}

// --- stream lifecycle ---
private extension NFTCollectionViewModel {
	func cancelFetchingTask() {
		fetchingTask?.cancel()
		fetchingTask = nil
	}
}

// --- updaters ---
private extension NFTCollectionViewModel {
	func switchLikeState(for model: NFTModelContainer, key id: String) {
		nfts.updateValue(
			.init(
				nft: model.nft,
				isFavorite: !model.isFavorite,
				isInCart: model.isInCart
			), forKey: id
		)
	}
	
	func switchCartState(for model: NFTModelContainer, key id: String) {
		nfts.updateValue(
			.init(
				nft: model.nft,
				isFavorite: model.isFavorite,
				isInCart: !model.isInCart
			), forKey: id
		)
	}
	
	func updateIDs() async throws {
		let newIDs: Set<String>
		if isFromCollection, let collectionID {
			newIDs = Set(try await loadCollection(collectionID).nftsIDs)
		} else if !isFromCollection, let authorID {
			newIDs = Set(try await loadAuthor(authorID).nftsIDs)
		} else {
			return
		}
		
		let oldIDs = Set(nfts.keys)
		
		let idsToAdd = newIDs.subtracting(oldIDs)
		let idsToRemove = oldIDs.subtracting(newIDs)
		
		let newIsEmpty = idsToAdd.isEmpty
		let removalIsEmpty = idsToRemove.isEmpty
		guard !newIsEmpty || !removalIsEmpty else { return }
		
		isLoaded = false
		
		if !removalIsEmpty {
			idsToRemove.forEach { nfts.removeValue(forKey: $0) }
			sortedKeys.removeAll(where: { idsToRemove.contains($0) })
			filteredKeys.removeAll(where: { idsToRemove.contains($0) })
			sortedKeys.removeAll(where: { idsToRemove.contains($0) })
		}
		
		if !newIsEmpty {
			nfts.reserveCapacity(nfts.count + idsToAdd.count)
			newIDs.forEach {
				nfts.updateValue(.none, forKey: $0)
				if !sortedKeys.contains($0) {
					sortedKeys.append($0)
				}
				
				if !filteredKeys.contains($0) {
					filteredKeys.append($0)
				}
			}
		}
		
		loadNilNFTsIfNeeded()
	}
}

// --- loaders ---
private extension NFTCollectionViewModel {
	func loadNilNFTsIfNeeded(isInitial: Bool = false) {
		let unloaded = nfts.filter(\.value.isNil).map(\.key)
		
		guard !unloaded.isEmpty else {
			if !sortedKeys.isEmpty && !isLoaded {
				applySort()
			}
			isLoaded = true
			return
		}
		
		let chunks = unloaded.chunked(into: 10)
		
		fetchingTask?.cancel()
		fetchingTask = Task {
			let favourites = await nftService.favouritesService.get()
			let order = await nftService.orderService.get()
			
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
					nfts[nft.id] = .init(
						nft: nft,
						isFavorite: favourites.contains(nft.id),
						isInCart: order.contains(nft.id)
					)
				}
			}
			
			guard !Task.isCancelled else { return }
			
			let failedCount = nfts.filter(\.value.isNil).count
			if failedCount > 0 {
				errorIsPresented = true
			} else {
				if !isInitial {
					withAnimation(Constants.defaultAnimation) {
						applySort()
					}
				}
			}
			
			isLoaded = true
		}
	}
}

// --- polling lifecycle ---
extension NFTCollectionViewModel {
	func startBackgroundUnloadedLoadPolling() {
		guard pollingTask == nil || pollingTask?.isCancelled ?? true else { return }
		
		pollingTask = Task(priority: .utility) {
			do {
				repeat {
					try await updateIDs()
					if isLoaded {
						loadNilNFTsIfNeeded()
					}
					try await Task.sleep(for: pollingInterval)
				} while !Task.isCancelled
			} catch is CancellationError {
				print("\(#function) cancelled")
			} catch {
				print("\(#function) failed with: \(error)")
				withAnimation(Constants.defaultAnimation) {
					errorIsPresented = true
				}
			}
		}
	}
	
	private func clearAllATasks() {
		cancelFetchingTask()
		
		pollingTask?.cancel()
		pollingTask = nil
	}
}
