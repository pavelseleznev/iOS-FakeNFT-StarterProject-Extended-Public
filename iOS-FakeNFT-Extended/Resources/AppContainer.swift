//
//  AppContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


struct AppContainer {
	let nft: NFTServiceProtocol
	let api: ObservedNetworkClient
    let profileProvider: ProfileProvider
    let profileService: ProfileService
    let favoriteStore = FavoriteNFTViewModel(items: NFTModel.favoriteMocks)
}
