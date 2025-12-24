//
//  MockProfileProvider.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import Foundation

struct MockProfileProvider: ProfileProvider {
    func profile() -> ProfileModel {
        ProfileModel(
            name: "Joaquin Phoenix",
            about: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.",
            website: "Joaquin Phoenix.com",
            avatarURL: "")
    }
}
