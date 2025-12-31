//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    
    var profile: ProfileModel { profileStore.profile }
    var loadErrorPresented = false
    var loadErrorMessage = "Не удалось загрузить данные"
        
    var myNFTTitle: String {
        "Мои NFT (\(myNFTStore.count))"
    }
    var favoriteTitle: String {
        "Избранные NFT (\(favoriteNFTStore.count))"
    }
    
    private let router: ProfileRouting
    private let service: ProfileService
    private let myNFTStore: MyNFTViewModel
    private let favoriteNFTStore: FavoriteNFTViewModel
    private let profileStore: ProfileStore
    private let api: ObservedNetworkClient
    private var hasLoadedNFTLists = false
    
    init(router: ProfileRouting,
         service: ProfileService,
         myNFTStore: MyNFTViewModel,
         favoriteNFTStore: FavoriteNFTViewModel,
         profileStore: ProfileStore,
         api: ObservedNetworkClient
    ) {
        self.router = router
        self.service = service
        self.myNFTStore = myNFTStore
        self.favoriteNFTStore = favoriteNFTStore
        self.profileStore = profileStore
        self.api = api
    }
    
    func load() async {
        do {
            try await profileStore.loadIfNeeded()
            
            guard !hasLoadedNFTLists else { return}
            hasLoadedNFTLists = true
            
            let liked = try await service.getNFTs(ids: profileStore.likes)
            favoriteNFTStore.items = liked.map(mapToNFTModel(isFavorite: true))
            
            let mine = try await service.getNFTs(ids: profileStore.nfts)
            myNFTStore.setItems(mine.map(mapToNFTModel(isFavorite: false)))
        } catch {
            guard !(error is CancellationError) else { return }
            print("Loading user profile failed:", error)
            hasLoadedNFTLists = false
            loadErrorMessage = "Не удалось загрузить данные"
            loadErrorPresented = true
        }
    }
    
    func retryLoad() async {
        hasLoadedNFTLists = false
        await load()
    }
    
    func websiteTapped() {
        router.showWebsite(url: profile.website)
    }
    
    func editTapped() {
        router.showEditProfile(profile: profileStore.profile)
    }
    
    func myNFTsTapped() {
        router.showMyNFTs()
    }
    
    func favoriteNFTsTapped() {
        router.showFavoriteNFTs()
    }
    
    private func mapToNFTModel(isFavorite: Bool) -> (NFTResponse) -> NFTModel {
        { dto in
            NFTModel(
                imageURLString: dto.imagesURLsStrings.first ?? "",
                name: dto.name,
                author: dto.authorSiteURL,
                cost: "\(dto.price) ETH",
                rate: "\(dto.ratingInt)/5",
                isFavorite: isFavorite,
                id: dto.id
            )
        }
    }
}
