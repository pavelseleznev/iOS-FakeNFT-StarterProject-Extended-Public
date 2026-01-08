//
//  AsyncNFTs.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 18.12.2025.
//

import SwiftUI

@MainActor
final class AsyncNFTs: ObservableObject {
	@Published private var nfts = [String : NFTModelContainer?]()
	private let authorID: String
	private let loadAuthor: (String) async throws -> UserListItemResponse
	var errorIsPresented = false
	
	private var currentStream: AsyncThrowingStream<NFTResponse, Error>?
	private var continuation: AsyncThrowingStream<NFTResponse, Error>.Continuation?
	private var pollingTask: Task<Void, Never>?
	private var fetchingTask: Task<Void, Error>?
	
	var activeTokens = [FilterToken]()
	private var searchText: String = ""
	private var viewDidDisappeared = false
	private var updatesID: UUID?
	
	private let didTapDetail: (NFTModelContainer, [Dictionary<String, NFTModelContainer?>.Element]) -> Void
	private let nftService: NFTServiceProtocol
	private let pollingInterval: Duration = .seconds(5)
	
	var visibleNFTs: [Dictionary<String, NFTModelContainer?>.Element] {
		withAnimation(.default) {
			nfts
				.sorted(by: sortComparator)
				.filter(filterApplier)
		}
	}
	
	init(
		loadAuthor: @escaping (String) async throws -> UserListItemResponse,
		nftService: NFTServiceProtocol,
		initialNFTsIDs: [String],
		authorID: String,
		didTapDetail: @escaping (NFTModelContainer, [Dictionary<String, NFTModelContainer?>.Element]) -> Void
	) {
		self.loadAuthor = loadAuthor
		self.nftService = nftService
		self.authorID = authorID
		self.didTapDetail = didTapDetail
		
		initialNFTsIDs.forEach { nfts[$0, default: nil] = nil }
	}
}

// MARK: - AsyncNFTs extensions

// --- internal helpers ---
extension AsyncNFTs {
	func didTapDetailOnCell(_ nft: NFTModelContainer) {
		guard !authorID.isEmpty else { return }
		didTapDetail(nft, visibleNFTs)
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
		
		objectWillChange.send()
	}
	
	func onDebounce(_ text: String) {
		searchText = text
	}
}

// --- private helpers ---
extension AsyncNFTs {
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
	
	func performWithTimeout<T: Sendable>(
		timeout: Duration,
		operation: @escaping @Sendable () async throws -> T
	) async throws -> T {
		try await withThrowingTaskGroup(of: Result<T, Error>.self) { group in
			group.addTask(priority: .userInitiated) {
				do {
					let result = try await operation()
					return .success(result)
				} catch {
					return .failure(error)
				}
			}
			
			group.addTask(priority: .userInitiated) {
				try await Task.sleep(for: timeout)
				return .failure(NSError(domain: "Timeout", code: 0, userInfo: nil))
			}
			
			if let firstResult = try await group.next() {
				group.cancelAll()
				
				switch firstResult {
				case .success(let value):
					return value
				case .failure(let error):
					throw error
				}
			}
			
			group.cancelAll()
			throw NSError(domain: "No value received", code: 0, userInfo: nil)
		}
	}
	
	func sortComparator(
		_ model1: [String : NFTModelContainer?].Element,
		_ model2: [String : NFTModelContainer?].Element
	) -> Bool {
		let activeSortOptions = activeTokens.filter(\.isSortOption)
		guard
			!activeSortOptions.isEmpty,
			let value1 = model1.value,
			let value2 = model2.value
		else {
			return model1.key.localizedStandardCompare(model2.key) == .orderedAscending
		}
		
		return activeSortOptions.allSatisfy { sortOption in
			switch sortOption {
			case .ratingAscending:
				value1.nft.rating < value2.nft.rating
			case .ratingDescending:
				value1.nft.rating > value2.nft.rating
			case .costAscending:
				value1.nft.price < value2.nft.price
			case .costDescending:
				value1.nft.price > value2.nft.price
			default:
				true
			}
		}
	}
	
	func filterApplier(_ model: [String : NFTModelContainer?].Element) -> Bool {
		guard let model = model.value else { return true }
		
		let matchesText = searchText.isEmpty ||
			model.nft.name.localizedCaseInsensitiveContains(searchText)
		
		let matchesTokens = activeTokens.allSatisfy { token in
			switch token {
			case .isFavourite:
				model.isFavorite
			case .isInCart:
				model.isInCart
			case .isNotFavourite:
				!model.isFavorite
			case .isNotInCart:
				!model.isInCart
			default:
				true
			}
		}
		
		return matchesText && matchesTokens
	}
}

// --- stream lifecycle ---
private extension AsyncNFTs {
	func cancelFetchingTask() {
		fetchingTask?.cancel()
		fetchingTask = nil
		
		continuation?.finish()
		continuation = nil
		currentStream = nil
	}
	
	func makeNFTsStream(with ids: [String]) -> AsyncThrowingStream<NFTResponse, Error> {
		if let currentStream {
			return currentStream
		} else {
			let stream = AsyncThrowingStream<NFTResponse, Error> { continuation in
				cancelFetchingTask()
				
				self.continuation = continuation
				
				fetchingTask = Task(priority: .userInitiated) {
					for id in ids {
						if viewDidDisappeared {
							cancelFetchingTask()
							return
						}
						
						let nft = try await performWithTimeout(
							timeout: Duration.seconds(3),
							operation: { [weak self] in
								guard let self else { throw NSError(domain: "Self is deallocated", code: 0) }
								return try await nftService.loadNFT(id: id)
							}
						)
						
						continuation.yield(nft)
					}
					continuation.finish()
				}
				
				continuation.onTermination = { _ in
					Task(priority: .utility) { [weak self] in
						await self?.cancelFetchingTask()
					}
				}
			}
			
			currentStream = stream
			return stream
		}
	}
}

// --- updaters ---
private extension AsyncNFTs {
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
		let newIDs = Set(try await loadAuthor(authorID).nftsIDs)
		let oldIDs = Set(nfts.keys)
		
		let idsToAdd = newIDs.subtracting(oldIDs)
		let idsToRemove = oldIDs.subtracting(newIDs)
		
		let newCapacity = oldIDs.count - idsToRemove.count + idsToAdd.count
		
		nfts.reserveCapacity(newCapacity)
		
		idsToRemove.forEach { nfts.removeValue(forKey: $0) }
		idsToAdd.forEach { nfts.updateValue(.none, forKey: $0) }
	}
}

// --- loaders ---
private extension AsyncNFTs {
	func loadUnloadedNFTsIfNeeded() async throws {
		let unloadedNFTs = nfts.filter(\.value.isNil)
		guard !unloadedNFTs.isEmpty else { return }
		
		try await loadNFTs(by: unloadedNFTs.map(\.key))
	}
	
	func loadNFTs(by ids: [String]) async throws {
		nfts.reserveCapacity(ids.count)
		ids.forEach { nfts[$0, default: nil] = nil }
		
		let favourites = await nftService.favouritesService.get()
		let order = await nftService.orderService.get()
		
		for try await nft in makeNFTsStream(with: ids) {
			let nftContainer = NFTModelContainer(
				nft: nft,
				isFavorite: favourites.contains(nft.id),
				isInCart: order.contains(nft.id)
			)
			nfts[nft.id, default: nil] = nftContainer
		}
	}
}

// --- polling lifecycle ---
extension AsyncNFTs {
	func startBackgroundUnloadedLoadPolling() {
		guard pollingTask == nil || pollingTask?.isCancelled ?? true else { return }
		
		pollingTask = Task(priority: .utility) {
			do {
				repeat {
					try await updateIDs()
					try await loadUnloadedNFTsIfNeeded()
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
