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
    
    func getNFTs(ids: [String]) async throws -> [NFTResponse] {
        try await withThrowingTaskGroup(of: (Int, NFTResponse).self) { group in
            for (index, id) in ids.enumerated() {
                group.addTask {
                    let dto = try await client.send(
                        NFTResponse.self,
                        request: GetNFTByIDRequest(id: id)
                    )
                    return (index, dto)
                }
            }
            
            var bucket: [(Int, NFTResponse)] = []
            for try await pair in group {
                bucket.append(pair)
            }
            
            return bucket.sorted { $0.0 < $1.0 }.map(\.1)
        }
    }
    
    func updateLikes(_ ids: [String]) async throws {
        let request = UpdateProfileLikesRequest(likeIDs: ids)
        _ = try await client.send(ProfileResponse.self, request: request)
    }
}
