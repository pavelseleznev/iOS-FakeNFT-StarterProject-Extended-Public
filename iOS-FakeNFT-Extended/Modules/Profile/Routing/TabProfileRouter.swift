//
//  TabProfileRouter.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import Foundation

struct TabProfileRouter: ProfileRouting {
    let push: (Page) -> Void
    
    func showWebsite(url: String) {
        push(.aboutAuthor(urlString: url))
    }
    
    func showEditProfile(profile: ProfileModel) {
        push(.editProfile(profile))
    }
}
