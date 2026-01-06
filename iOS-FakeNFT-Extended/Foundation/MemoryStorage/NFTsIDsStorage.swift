//
//  NFTsIDsStorageProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

import Foundation


protocol NFTsIDsStorageProtocol: Sendable, AnyObject {
    func get() async -> Set<String>
    func replaceIDs<S: Sequence & Sendable>(withLoaded ids: S) async where S.Element == String
    func add(_ id: String) async
    func remove(_ id: String) async
    func clear() async
}

actor NFTsIDsStorage: NFTsIDsStorageProtocol {
    private var ids = Set<String>() {
        didSet {
            storage.set(Array(ids), forKey: userDefaultsKey)
        }
    }
    private let userDefaultsKey: String
    private let storage = UserDefaults.standard // hardcode
    
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        
        if let value = storage.value(forKey: userDefaultsKey) as? [String] {
            ids = Set(value)
        }
    }
}

// MARK: - NFTsIDsStorage Extensions
// --- methods ---
extension NFTsIDsStorage {
    func get() -> Set<String> {
        ids
    }
    
    func replaceIDs<S: Sequence & Sendable>(withLoaded ids: S) async where S.Element == String {
        self.ids = Set(ids)
    }
    
    func add(_ id: String) {
        ids.insert(id)
    }
    
    func remove(_ id: String) {
        ids.remove(id)
    }
    
    func clear() {
        ids = []
    }
}
