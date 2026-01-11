//
//  ProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

protocol ProfileServiceProtocol: Sendable {
	func performUpdatesIfNeeded() async throws -> ProfileResponse
	func get() async -> ProfileContainerModel
	func update(with model: ProfileContainerModel) async throws
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
	func update(with model: ProfileContainerModel) async throws {
		await storage.update(with: model)
		do {
			try await api.updateProfile(payload: .init(from: model))
		} catch {
			// restoring data after server abort
			if let actual = try? await loadProfile() {
				await storage.updateFully(with: .init(from: actual))
			}
			
			throw error
		}
	}
	
	func get() async -> ProfileContainerModel {
		await storage.get()
	}
	
	func performUpdatesIfNeeded() async throws -> ProfileResponse {
		let loadedProfile = try await loadProfile()

		await storage.update(with: .init(from: loadedProfile))
		return loadedProfile
	}
	
	func loadProfile() async throws -> ProfileResponse {
		try await api.getProfile()
	}
}
