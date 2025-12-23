//
//  DefaultProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/22/25.
//

import Foundation

struct DefaultProfileService: ProfileService {
    let client: NetworkClient
    
    func fetchProfile() async throws -> ProfileModel {
        let dto = try await client.send(ProfileResponse.self, request: GetProfileRequest())
        return ProfileModel(
            name: dto.name,
            about: dto.description,
            website: dto.website,
            avatarURL: dto.avatar)
    }
}
