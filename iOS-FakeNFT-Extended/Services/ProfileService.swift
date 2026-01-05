//
//  ProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

protocol ProfileServiceProtocol: Sendable {
	func get() async -> ProfilePayload
	func update(with model: ProfilePayload) async throws
	func loadProfileAndSave() async throws
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
	
	func loadProfileAndSave() async throws {
		let profile = try await loadProfile()
		await storage.updateFully(with: profile)
	}
	
	func loadProfile() async throws -> ProfileResponse {
		try await api.getProfile()
	}
}
