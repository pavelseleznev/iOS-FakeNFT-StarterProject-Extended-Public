//
//  ProfileStorageProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

import Foundation


protocol ProfileStorageProtocol: Sendable, AnyObject {
	func get() async -> ProfilePayload

	func update(with model: ProfilePayload) async
	func updateFully(with model: ProfileResponse) async
}


enum ProfileStorageKey {
	case name, avatarURLString, description, websiteURLString
	
	var key: String {
		switch self {
		case .name:
			"ProfileStorage.name"
		case .avatarURLString:
			"ProfileStorage.avatarURLString"
		case .description:
			"ProfileStorage.description"
		case .websiteURLString:
			"ProfileStorage.websiteURLString"
		}
	}
	
	var notificationName: Notification.Name {
		switch self {
		case .name:
			.profileNameDidChange
		case .avatarURLString:
			.profileAvatarDidChange
		case .description:
			.profileDescriptionDidChange
		case .websiteURLString:
			.profileWebsiteDidChange
		}
	}
}



actor ProfileStorage: ProfileStorageProtocol {
	private var name = ""
	private var avatarURLString = ""
	private var description = ""
	private var websiteURLString = ""
	
	private let storage = StorageActor.shared
	private var saveTasks = [ProfileStorageKey : Task<Void, Never>]()
	
	init() {
		Task(priority: .userInitiated) {
			await self.restoreFromStorage()
		}
	}
	
	private func restoreFromStorage() async {
		async let _name: String? = await storage.value(
			forKey: ProfileStorageKey.name.key
		)
		async let _avatar: String? = await storage.value(
			forKey: ProfileStorageKey.avatarURLString.key
		)
		async let _dscr: String? = await storage.value(
			forKey: ProfileStorageKey.description.key
		)
		async let _web: String? = await storage.value(
			forKey: ProfileStorageKey.websiteURLString.key
		)
		
		let (n, a, d, w) = await (_name, _avatar, _dscr, _web)
		
		if let n { name = n }
		if let a { avatarURLString = a }
		if let d { description = d }
		if let w { websiteURLString = w }
		
		print("\nProfileStorage restored from storage")
	}

	private func notifyForUpdates(newValue: String, kind: ProfileStorageKey) {
		Task { @MainActor in
			NotificationCenter.default.post(
				name: kind.notificationName,
				object: nil,
				userInfo: [kind.key : newValue]
			)
		}
	}
	
	private func scheduleSave(newValue: String, kind: ProfileStorageKey) {
		saveTasks[kind]?.cancel()
		saveTasks[kind] = Task {
			try? await Task.sleep(for: .seconds(0.5))
			guard !Task.isCancelled else { return }
			
			await storage.set(newValue, forKey: kind.key)
			print("Saved: \(kind.key)")
		}
	}
	
	private func updateField(_ currenctValue: inout String, newValue: String, kind: ProfileStorageKey) {
		guard currenctValue != newValue else { return }
		
		currenctValue = newValue
		
		notifyForUpdates(newValue: newValue, kind: kind)
		scheduleSave(newValue: newValue, kind: kind)
	}
}

// MARK: - ProfileStorage Extensions
// --- getters ---
extension ProfileStorage {
	func get() async -> ProfilePayload {
		.init(
			name: name,
			description: description,
			avatar: avatarURLString,
			website: websiteURLString
		)
	}
}

// --- updates ---
extension ProfileStorage {
	func update(with model: ProfilePayload) async {
		if let _name = model.name {
			updateField(&name, newValue: _name, kind: .name)
		}
		
		if let _avatarURLString = model.avatar {
			updateField(&avatarURLString, newValue: _avatarURLString, kind: .avatarURLString)
		}
		
		if let _websiteURLString = model.website {
			updateField(&websiteURLString, newValue: _websiteURLString, kind: .websiteURLString)
		}
		
		if let _description = model.description {
			updateField(&description, newValue: _description, kind: .description)
		}
	}
	
	func updateFully(with model: ProfileResponse) async {
		updateField(
			&name,
			newValue: model.name,
			kind: .name
		)
		updateField(
			&avatarURLString,
			newValue: model.avatar,
			kind: .avatarURLString
		)
		updateField(
			&websiteURLString,
			newValue: model.website,
			kind: .websiteURLString
		)
		updateField(
			&description,
			newValue: model.description,
			kind: .description
		)
	}
}
