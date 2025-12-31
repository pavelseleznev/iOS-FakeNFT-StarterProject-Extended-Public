//
//  TabProfileRouter.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import SwiftUI

struct ProfileRootView: View {
    let profile: ProfileContext
    let appContainer: AppContainer
    let push: (Page) -> Void
    
    var body: some View {
        let store = profile.store
        let service = profile.service
        ProfileView(
            router: Router(push: push),
            service: service,
            myNFTStore: profile.myNFTStore,
            favoriteNFTStore: profile.favoriteNFTStore,
            profileStore: store,
            api: appContainer.api
        )
    }
}

private struct Router: ProfileRouting {
    let push : (Page) -> Void
    
    func showWebsite(url: String) {
        push(.aboutAuthor(urlString: url))
    }
    
    func showEditProfile(profile: ProfileModel) {
        push(.editProfile(profile))
    }
    
    func showMyNFTs() {
        push(.myNFTs)
    }
    
    func showFavoriteNFTs() {
        push(.favoriteNFTs)
    }
}
