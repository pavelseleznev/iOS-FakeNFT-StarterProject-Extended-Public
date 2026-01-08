//
//  ProfileStorageProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

import Foundation


protocol ProfileStorageProtocol: Sendable, AnyObject {
	func get() async -> ProfileContainerModel
	
	func update(with model: ProfileContainerModel) async
	func updateFully(with model: ProfileContainerModel) async
}

actor ProfileStorage: ProfileStorageProtocol {
	private var profile = ProfileContainerModel()
	
	private let storage = StorageActor.shared
	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()
	private var saveTask: Task<Void, Never>?
	
	init() {
		Task(priority: .userInitiated) {
			await self.restoreFromStorage()
		}
	}
	
	private func restoreFromStorage() async {
		if
			let profileData: Data = await storage.value(forKey: Constants.profileStorageKey),
			let decoded = try? decoder.decode(ProfileContainerModel.self, from: profileData)
		{
			profile = decoded
			print("\nProfileStorage restored from storage")
		} else {
			print("\nProfileStorage has not been restored from storage")
		}
	}
	
	private func notifyForUpdates(newValue: ProfileContainerModel) {
		Task { @MainActor in
			NotificationCenter.default.post(
				name: .profileDidUpdate,
				object: nil,
				userInfo: [Constants.profileStorageKey : newValue]
			)
		}
	}
	
	private func scheduleSave(newValue: ProfileContainerModel) {
		saveTask?.cancel()
		saveTask = Task {
			do {
				try await Task.sleep(for: .seconds(0.5))
				guard !Task.isCancelled else { return }
				
				let encoded = try encoder.encode(newValue)
				await storage.set(encoded, forKey: Constants.profileStorageKey)
				print("\nSaved: profile")
			} catch is CancellationError {
				return
			} catch {
				print("\nFailed to save: profile (\(error.localizedDescription))")
			}
		}
	}
}

// MARK: - ProfileStorage Extensions
// --- getters ---
extension ProfileStorage {
	func get() async -> ProfileContainerModel {
		profile
	}
}

// --- updates ---
extension ProfileStorage {
	func update(with model: ProfileContainerModel) async {
		let candidate = ProfileContainerModel(
			name: model.name ?? profile.name,
			avatarURLString: model.avatarURLString ?? profile.avatarURLString,
			websiteURLString: model.websiteURLString ?? profile.websiteURLString,
			description: model.description ?? profile.description,
			nftsIDs: model.nftsIDs ?? profile.nftsIDs,
			favoritesIDs: model.favoritesIDs ?? profile.favoritesIDs
		)
		
		guard candidate != profile else { return }
		
		profile = candidate
		notifyForUpdates(newValue: candidate)
		scheduleSave(newValue: candidate)
	}
	
	func updateFully(with model: ProfileContainerModel) async {
		profile = model
		notifyForUpdates(newValue: model)
		scheduleSave(newValue: model)
	}
}
