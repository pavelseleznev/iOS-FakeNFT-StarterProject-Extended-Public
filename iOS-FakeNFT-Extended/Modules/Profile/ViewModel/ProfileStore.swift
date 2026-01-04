//
//  ProfileStore.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/27/25.
//

import Foundation

@MainActor
@Observable
final class ProfileStore {
    
    var loadingState: LoadingState = .idle
    private(set) var profile: ProfileModel
    private(set) var likes: [String] = []
    private(set) var nfts: [String] = []
    private var hasLoaded = false
    
    private let api: ObservedNetworkClient
    
    init(api: ObservedNetworkClient, initial: ProfileModel) {
        self.api = api
        self.profile = initial
    }
    
    func loadIfNeeded() async throws {
        guard !hasLoaded else { return }
        try await reload()
    }
    
    func reload() async throws {
        loadingState = .fetching
        defer { loadingState = .idle }
        
        do {
            let dto = try await api.getProfile()
            apply(dto)
            hasLoaded = true
        }
    }
    
    func updateProfile(with edited: ProfileModel) async throws {
        loadingState = .fetching
        defer { loadingState = .idle }
        
        let payload = ProfilePayload(
            name: edited.name,
            description: edited.about,
            avatar: edited.avatarURL,
            website: edited.website
        )
        
        let dto = try await api.updateProfile(payload: payload)
        apply(dto)
        hasLoaded = true
    }
    
    private func apply(_ dto: ProfileResponse) {
        profile = ProfileModel(
            name: dto.name,
            about: dto.description,
            website: dto.website,
            avatarURL: dto.avatar
        )
        likes = dto.likes
        nfts = dto.nfts
    }
}

extension ProfileStore {
    static var preview: ProfileStore {
        ProfileStore(api: .preview, initial: .preview)
    }
}
