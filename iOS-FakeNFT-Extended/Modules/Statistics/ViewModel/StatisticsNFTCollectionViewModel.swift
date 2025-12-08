//
//  StatisticsNFTCollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import Observation

@MainActor
@Observable
final class StatisticsNFTCollectionViewModel {
	let nfts: [NFTModel]
	private let api: ObservedNetworkClient
	
	init(nfts: [NFTModel], api: ObservedNetworkClient) {
		self.nfts = nfts
		self.api = api
	}
}

extension StatisticsNFTCollectionViewModel {
	func didTapLikeButton(for nft: NFTModel) {}
	func didTapCartButton(for nft: NFTModel) {}
}
