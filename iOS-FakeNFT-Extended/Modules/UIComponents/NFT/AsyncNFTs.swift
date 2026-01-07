//
//  AsyncNFTs.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 18.12.2025.
//

import Foundation

@MainActor
final class AsyncNFTs: ObservableObject {
	@Published private var nfts = [String : NFTModelContainer?]()
	private var failedIDs = Set<String>()
	
	private var currentStream: AsyncStream<NFTResponse>?
	private var continuation: AsyncStream<NFTResponse>.Continuation?
	private var fetchingTask: Task<Void, Never>?
	
	private var viewDidDisappeared = false
	
	private let nftService: NFTServiceProtocol
	
	@inline(__always)
	var visibleNFTs: [NFTModelContainer?] {
		nfts
			.sorted {
				$0.key.localizedStandardCompare($1.key) == .orderedAscending
			}
			.map(\.value)
	}
	
	init(nftService: NFTServiceProtocol) {
		self.nftService = nftService
	}
}

extension AsyncNFTs {
	func didTapLikeButton(for model: NFTModelContainer?) {
		guard let model else { return }
		
		switchLikeState(for: model, key: model.id)
		Task {
            do {
                if await nftService.favouritesService.contains(model.id) {
                    try await nftService.removeFromFavourites(nftID: model.id)
                } else {
                    try await nftService.addToFavourites(nftID: model.id)
                }
            } catch {
                print("Failed to send like. \(error)")
            }
		}
	}
	
	func didTapCartButton(for model: NFTModelContainer?) {
		guard let model else { return }
		
		switchCartState(for: model, key: model.id)
		Task {
            do {
                if await nftService.orderService.contains(model.id) {
                    try await nftService.removeFromCart(nftID: model.id)
                } else {
                    try await nftService.addToCart(nftID: model.id)
                }
            } catch {
                print("Failed to add to cart. \(error)")
            }
		}
	}
	
	func viewDidDissappear() {
		viewDidDisappeared = true
		cancelFetchingTask()
	}
}

extension AsyncNFTs {
	func loadFailedNFTs() async {
		await fetchNFTs(using: failedIDs)
	}
	
	func fetchNFTs(using ids: Set<String>) async {
		nfts.reserveCapacity(ids.count)
		ids.forEach { nfts[$0, default: nil] = nil }
		
		for await nft in makeNFTsStream(with: ids) {
			let nftContainer = NFTModelContainer(
				nft: nft,
                isFavorite: await nftService.favouritesService.contains(nft.id),
                isInCart: await nftService.orderService.contains(nft.id)
			)
			nfts[nft.id, default: nil] = nftContainer
		}
	}
}

private extension AsyncNFTs {
	func cancelFetchingTask() {
		fetchingTask?.cancel()
		fetchingTask = nil
		
		continuation?.finish()
		continuation = nil
		currentStream = nil
	}
	
	func makeNFTsStream(with ids: Set<String>) -> AsyncStream<NFTResponse> {
		if let currentStream {
			return currentStream
		} else {
			let stream = AsyncStream<NFTResponse> { continuation in
				cancelFetchingTask()
				
				self.continuation = continuation
				
				fetchingTask = Task {
					for id in ids {
						if viewDidDisappeared {
							cancelFetchingTask()
						}
						
						do {
							let nft = try await performWithTimeout(
								timeout: Duration.seconds(3),
								operation: { [weak self] in
									guard let self else { throw NSError(domain: "Self is deallocated", code: 0) }
									return try await nftService.loadNFT(id: id)
								}
							)
							
							failedIDs.remove(id)
							continuation.yield(nft)
						} catch {
							failedIDs.insert(id)
						}
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
	
	func performWithTimeout<T: Sendable>(
		timeout: Duration,
		operation: @escaping @Sendable () async throws -> T
	) async throws -> T {
		try await withThrowingTaskGroup(of: Result<T, Error>.self) { group in
			group.addTask {
				do {
					let result = try await operation()
					return .success(result)
				} catch {
					return .failure(error)
				}
			}
			
			group.addTask {
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
}
