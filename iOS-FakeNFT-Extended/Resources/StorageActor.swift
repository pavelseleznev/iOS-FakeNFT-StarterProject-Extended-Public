//
//  PrimitiveType.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.01.2026.
//

import Foundation

protocol PrimitiveType: Codable {}
extension Bool: PrimitiveType {}
extension String: PrimitiveType {}
extension Array: PrimitiveType where Element == String {}
extension Data: PrimitiveType {}

@globalActor
actor StorageActor {
	static let shared = StorageActor()
	private let storage = UserDefaults.standard
	
	func set<T: PrimitiveType>(_ value: T, forKey key: String) {
		storage.set(value, forKey: key)
		
		guard
			key == Constants.isAuthedKey,
			let isAuthed = value as? Bool
		else { return }
		Task(priority: .userInitiated) { @MainActor in
			NotificationCenter.default.post(
				name: .authStateChanged,
				object: nil,
				userInfo: [Constants.isAuthedKey : isAuthed]
			)
			print("\nAuth notification sent: \(isAuthed)")
		}
	}
	
	func value<T: PrimitiveType>(forKey key: String) -> T? {
		storage.value(forKey: key) as? T
	}
}

extension UserDefaults {
	@objc dynamic var isAuthed: Bool {
		bool(forKey: Constants.isAuthedKey)
	}
}
