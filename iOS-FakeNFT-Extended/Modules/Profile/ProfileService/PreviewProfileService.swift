//
//  PreviewProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/30/25.
//

import Foundation

struct PreviewProfileService: ProfileService {
    
    func fetchProfile() async throws -> ProfileModel {
        .preview
    }
    
    func getNFTs(ids: [String]) async throws -> [NFTResponse] {
        ids.map {
            NFTResponse(
                createdAt: "Preview",
                name: "Preview",
                imagesURLsStrings: ["Preview"],
                ratingInt: 4,
                description: "Preview",
                price: 1.2,
                authorSiteURL: "Preview",
                id: $0
            )
        }
    }
    
    func updateLikes(_ ids: [String]) async throws {}
}
