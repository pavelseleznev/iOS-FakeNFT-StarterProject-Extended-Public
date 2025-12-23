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
    private let router: ProfileRouting
    private let service: ProfileService
    private let favoriteStore: FavoriteNFTViewModel
    
    var loadingState: LoadingState = .idle
    var favoriteTitle: String {
        "Избранные NFT (\(favoriteStore.count))"
    }
    private var hasLoadedProfile = false
    private(set) var profile: ProfileModel
    
    init(profile: ProfileModel, router: ProfileRouting, service: ProfileService, favoriteStore: FavoriteNFTViewModel) {
        self.profile = profile
        self.router = router
        self.service = service
        self.favoriteStore = favoriteStore
    }
    
    func load() async {
        guard !hasLoadedProfile else { return }
        
        loadingState = .fetching
        defer {
            loadingState = .idle
        }
        
        do {
            profile = try await service.fetchProfile()
            hasLoadedProfile = true
        } catch {
            // later: set an error flag + show retry alert
            print("Profile load failed:", error)
        }
    }
    
    func websiteTapped() {
        router.showWebsite(url: profile.website)
    }
    
    func editTapped() {
        router.showEditProfile(profile: profile)
    }
    
    func myNFTsTapped() {
        router.showMyNFTs()
    }
    
    func favoriteNFTsTapped() {
        router.showFavoriteNFTs()
    }
}
