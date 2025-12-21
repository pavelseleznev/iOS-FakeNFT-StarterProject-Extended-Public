//
//  AsyncNFTs.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 18.12.2025.
//

import Foundation

@MainActor
final class AsyncNFTs: ObservableObject {
	@Published private(set) var nfts = [NFTModelContainer]()
	@Published private(set) var failedIDs = Set<String>()
	
	private let nftService: NFTServiceProtocol
	
	init(nftService: NFTServiceProtocol) {
		self.nftService = nftService
	}
}

extension AsyncNFTs {
	func didTapLikeButton(for model: NFTModelContainer, at index: Int) {
		switchLikeState(for: model, at: index)
		Task {
			if await nftService.isFavourite(id: model.id) {
				await nftService.removeFromFavourite(id: model.id)
			} else {
				await nftService.addToFavourite(id: model.id)
			}
		}
	}
	
	func didTapCartButton(for model: NFTModelContainer, at index: Int) {
		switchCartState(for: model, at: index)
		Task {
			if await nftService.isInCart(id: model.id) {
				await nftService.removeFromCart(id: model.id)
			} else {
				await nftService.addToCart(id: model.id)
			}
		}
	}
}

extension AsyncNFTs {
	func loadFailedNFTs() async {
		await fetchNFTs(using: failedIDs)
	}
	
	func fetchNFTs(using ids: Set<String>) async {
		nfts.reserveCapacity(ids.count)
		
		for await nft in makeNFTsStream(with: ids) {
			nfts.append(
				.init(
					nft: nft,
					isFavorite: await nftService.isFavourite(id: nft.id),
					isInCart: await nftService.isInCart(id: nft.id)
				)
			)
		}
	}
}

private extension AsyncNFTs {
	func makeNFTsStream(with ids: Set<String>) -> AsyncStream<NFTResponse> {
		.init { continuation in
			Task {
				for id in ids {
					do {
						let nft = try await nftService.loadNFT(id: id)
						failedIDs.remove(id)
						continuation.yield(nft)
					} catch {
						failedIDs.insert(id)
					}
				}
				continuation.finish()
			}
		}
	}
	
	func switchLikeState(for model: NFTModelContainer, at index: Int) {
		nfts[index] = .init(
			nft: model.nft,
			isFavorite: !model.isFavorite,
			isInCart: model.isInCart
		)
	}
	
	func switchCartState(for model: NFTModelContainer, at index: Int) {
		nfts[index] = .init(
			nft: model.nft,
			isFavorite: model.isFavorite,
			isInCart: !model.isInCart
		)
	}
}
