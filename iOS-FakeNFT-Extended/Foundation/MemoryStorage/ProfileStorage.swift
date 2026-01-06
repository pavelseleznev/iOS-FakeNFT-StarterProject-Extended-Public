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

fileprivate let profileStorageNameKey: String = "ProfileStorage.name"
fileprivate let profileStorageAvatarURLStringKey: String = "ProfileStorage.avatarURLString"
fileprivate let profileStorageDescriptionKey: String = "ProfileStorage.description"
fileprivate let profileStorageWebsiteURLStringKey: String = "ProfileStorage.websiteURLString"

actor ProfileStorage: ProfileStorageProtocol {
    private var name: String {
        didSet {
            storage.set(name, forKey: profileStorageNameKey)
        }
    }
    private var avatarURLString: String {
        didSet {
            storage.set(avatarURLString, forKey: profileStorageAvatarURLStringKey)
        }
    }
    private var description: String {
        didSet {
            storage.set(description, forKey: profileStorageDescriptionKey)
        }
    }
    private var websiteURLString: String {
        didSet {
            storage.set(websiteURLString, forKey: profileStorageWebsiteURLStringKey)
        }
    }
    
    private let storage = UserDefaults.standard // hardcode
    
    init() {
        name = storage.string(forKey: profileStorageNameKey) ?? ""
        avatarURLString = storage.string(forKey: profileStorageAvatarURLStringKey) ?? ""
        description = storage.string(forKey: profileStorageDescriptionKey) ?? ""
        websiteURLString = storage.string(forKey: profileStorageWebsiteURLStringKey) ?? ""
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
        name = model.name ?? name
        avatarURLString = model.avatar ?? avatarURLString
        websiteURLString = model.website ?? websiteURLString
        description = model.description ?? description
    }
    
    func updateFully(with model: ProfileResponse) async {
        name = model.name
        avatarURLString = model.avatar
        websiteURLString = model.website
        description = model.description
    }
}
