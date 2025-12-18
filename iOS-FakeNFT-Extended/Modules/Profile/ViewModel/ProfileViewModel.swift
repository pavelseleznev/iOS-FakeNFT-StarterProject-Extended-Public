//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import Foundation

@Observable
final class ProfileViewModel {
    private let router: ProfileRouting
    private(set) var profile: ProfileModel
    
    init(profile: ProfileModel, router: ProfileRouting) {
        self.profile = profile
        self.router = router
    }
    
    func websiteTapped() {
        router.showWebsite(url: profile.website)
    }
    
    func editTapped() {
        router.showEditProfile(profile: profile)
    }
}
