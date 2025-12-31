//
//  ProfileContext.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/31/25.
//

import Foundation

@MainActor
final class ProfileContext {
    let service: ProfileService
    let store: ProfileStore
    let myNFTStore: MyNFTViewModel
    let favoriteNFTStore: FavoriteNFTViewModel

    init(api: ObservedNetworkClient, initialProfile: ProfileModel, service: ProfileService) {
        self.service = service
        self.store = ProfileStore(api: api, initial: initialProfile)
        self.myNFTStore = MyNFTViewModel()
        self.favoriteNFTStore = FavoriteNFTViewModel(items: [], service: service)
    }
}
