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
	private let ids: Set<String>
	var errorIsPresented = false
	
	private var currentStream: AsyncThrowingStream<NFTResponse, Error>?
	private var continuation: AsyncThrowingStream<NFTResponse, Error>.Continuation?
	private var pollingTask: Task<Void, Never>?
	private var fetchingTask: Task<Void, Error>?
	
	private var viewDidDisappeared = false
	
	private let nftService: NFTServiceProtocol
	private let pollingInterval: Duration = .seconds(1)
	
	@inline(__always)
	var visibleNFTs: [NFTModelContainer?] {
		nfts
			.sorted {
				$0.key.localizedStandardCompare($1.key) == .orderedAscending
			}
			.map(\.value)
	}
	
	init(
		nftService: NFTServiceProtocol,
		ids: Set<String>
	) {
		self.nftService = nftService
		self.ids = ids
	}
}

// MARK: - AsyncNFTs extensions

// --- internal helpers ---
extension AsyncNFTs {
	func didTapLikeButton(for model: NFTModelContainer?) {
		guard let model else { return }
		
		switchLikeState(for: model, key: model.id)
		Task(priority: .background) {
			if await nftService.isFavourite(id: model.id) {
				await nftService.removeFromFavourite(id: model.id)
			} else {
				await nftService.addToFavourite(id: model.id)
			}
		}
	}
	
	func didTapCartButton(for model: NFTModelContainer?) {
		guard let model else { return }
		
		switchCartState(for: model, key: model.id)
		Task(priority: .background) {
			if await nftService.isInCart(id: model.id) {
				await nftService.removeFromCart(id: model.id)
			} else {
				await nftService.addToCart(id: model.id)
			}
		}
	}
	
	func viewDidDissappear() {
		viewDidDisappeared = true
		cancelFetchingTask()
	}
}

// --- private helpers ---
extension AsyncNFTs {
	func handleNFTChangeNotification(notification: Notification) {
		if
			let payload = notification.userInfo?[Constants.nftChangePayloadKey] as? NFTUpdatePayload,
			payload.hasChanges,
			let model = nfts[payload.id],
			let model
		{
			if payload.isCartChanged {
				didTapCartButton(for: model)
			}
			
			if payload.isFavoriteChanged {
				didTapLikeButton(for: model)
			}
		}
	}
	
	func performWithTimeout<T: Sendable>(
		timeout: Duration,
		operation: @escaping @Sendable () async throws -> T
	) async throws -> T {
		try await withThrowingTaskGroup(of: Result<T, Error>.self) { group in
			group.addTask(priority: .high) {
				do {
					let result = try await operation()
					return .success(result)
				} catch {
					return .failure(error)
				}
			}
			
			group.addTask(priority: .high) {
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
				
				fetchingTask = Task(priority: .background) {
					for id in ids {
						if viewDidDisappeared {
							cancelFetchingTask()
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
					Task { [weak self] in
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
		nfts[id] = .init(
			nft: model.nft,
			isFavorite: !model.isFavorite,
			isInCart: model.isInCart
		)
	}
	
	func switchCartState(for model: NFTModelContainer, key id: String) {
		nfts[id] = .init(
			nft: model.nft,
			isFavorite: model.isFavorite,
			isInCart: !model.isInCart
		)
	}
	
	func updateIDs() {
		let oldIDs = Set(nfts.keys)
		let newIDs = ids
		
		let idsToAdd = newIDs.subtracting(oldIDs)
		let idsToRemove = oldIDs.subtracting(newIDs)
		
		let newCapacity = oldIDs.count - idsToRemove.count + idsToAdd.count
		nfts.reserveCapacity(newCapacity)
		
		idsToRemove.forEach { nfts.removeValue(forKey: $0) }
		idsToAdd.forEach { nfts[$0, default: nil] = nil }
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
		
		for try await nft in makeNFTsStream(with: ids) {
			let nftContainer = NFTModelContainer(
				nft: nft,
				isFavorite: await nftService.isFavourite(id: nft.id),
				isInCart: await nftService.isInCart(id: nft.id)
			)
			nfts[nft.id, default: nil] = nftContainer
		}
	}
}

// --- polling lifecycle ---
extension AsyncNFTs {
	func startBackgroundUnloadedLoadPolling() {
		guard pollingTask == nil else { return }
		
		pollingTask = Task(priority: .background) {
			do {
				repeat {
					updateIDs()
					try await loadUnloadedNFTsIfNeeded()
					try await Task.sleep(for: pollingInterval)
				} while !Task.isCancelled
			} catch {
				guard !(error is CancellationError) else { return }
				withAnimation(Constants.defaultAnimation) {
					errorIsPresented = true
				}
			}
		}
	}
	
	func clearAllATasks() {
		cancelFetchingTask()
		
		pollingTask?.cancel()
		pollingTask = nil
	}
}
