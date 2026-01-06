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
    
    var loadErrorPresented = false
    var loadErrorMessage = "Не удалось загрузить данные"
    
    var myNFTTitle: String { "Мои NFT (\(myNFTCount))" }
    var favoriteTitle: String { "Избранные NFT (\(favoriteCount))" }
    
    private(set) var profile: ProfileModel = .init(
        name: "",
        about: "",
        website: "",
        avatarURL: ""
    )
    
    private(set) var myNFTCount: Int = 0
    private(set) var favoriteCount: Int = 0
    
    private var hasLoaded = false
    private let appContainer: AppContainer
    private let push: (Page) -> Void
    
    init(
        appContainer: AppContainer,
        push: @escaping (Page) -> Void
    ) {
        self.appContainer = appContainer
        self.push = push
    }
    
    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        do {
            defer { hasLoaded = false }
            let payload = await appContainer.profileService.get()
            profile = ProfileModel(
                name: payload.name ?? "",
                about: payload.description ?? "",
                website: payload.website ?? "",
                avatarURL: payload.avatar ?? ""
            )
            
            let purchasedNFTs = await appContainer.purchasedNFTsService.get()
            let favoriteNFTs = await appContainer.nftService.favouritesService.get()
            
            myNFTCount = purchasedNFTs.count
            favoriteCount = favoriteNFTs.count
        }
    }
    
    func retryLoad() async {
        hasLoaded = false
        await load()
    }
    
    func websiteTapped() { push(.aboutAuthor(urlString: profile.website)) }
    
    func editTapped() { push(.profile(.editProfile(profile))) }
    
    func myNFTsTapped() { push(.profile(.myNFTs)) }
    
    func favoriteNFTsTapped() { push(.profile(.favoriteNFTs)) }
}
