//
//  AppContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


@MainActor
struct AppContainer {
	let nft: NFTServiceProtocol
	let api: ObservedNetworkClient
    let profileProvider: ProfileProvider
    let profileService: ProfileService
    let profileStore: ProfileStore
    let myNFTStore: MyNFTViewModel
    let favoriteNFTStore: FavoriteNFTViewModel
    
    init(
        nft: NFTServiceProtocol,
        api: ObservedNetworkClient,
        profileProvider: ProfileProvider,
        profileService: ProfileService
    ) {
        self.nft = nft
        self.api = api
        self.profileProvider = profileProvider
        self.profileService = profileService
        self.myNFTStore = MyNFTViewModel()
        self.favoriteNFTStore = FavoriteNFTViewModel(
            items: [],
            service: profileService
        )
        self.profileStore = ProfileStore(
            api: api, initial:
            profileProvider.profile()
        )
    }
}
