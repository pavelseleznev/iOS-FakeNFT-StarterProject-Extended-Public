//
//  ProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

protocol ProfileServiceProtocol: Sendable {
	func performUpdatesIfNeeded() async throws -> ProfileResponse
	func get() async -> ProfilePayload
	func update(with model: ProfilePayload) async throws
	func loadProfile() async throws -> ProfileResponse
}

actor ProfileService: ProfileServiceProtocol {
	private let api: ObservedNetworkClient
	private let storage: ProfileStorageProtocol
	
	init(api: ObservedNetworkClient, storage: ProfileStorageProtocol) {
		self.api = api
		self.storage = storage
	}
}

// MARK: - ProfileService Extensions
// --- methods ---
extension ProfileService {
	func update(with model: ProfilePayload) async throws {
		await storage.update(with: model)
		try await api.updateProfile(payload: model)
	}
	
	func get() async -> ProfilePayload {
		await storage.get()
	}
	
	func performUpdatesIfNeeded() async throws -> ProfileResponse {
		let loadedProfile = try await loadProfile()
		let currentProfile = await get()
		
		guard
			loadedProfile.name != currentProfile.name ||
			loadedProfile.avatar != currentProfile.avatar ||
			loadedProfile.website != currentProfile.website ||
			loadedProfile.description != currentProfile.description
		else { return loadedProfile }
		
		await storage.updateFully(with: loadedProfile)
		return loadedProfile
	}
	
	func loadProfile() async throws -> ProfileResponse {
		try await api.getProfile()
	}
}
