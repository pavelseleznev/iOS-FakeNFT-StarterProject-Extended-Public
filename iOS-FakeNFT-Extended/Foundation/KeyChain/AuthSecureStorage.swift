//
//  KeyChain.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//

import Foundation
import Security

enum KeychainError: Error {
	case unhandled(OSStatus)
	case duplicateItem
	case itemNotFound
	case invalidQuery
	
	var localizedDescription: String {
		switch self {
		case .unhandled(let status):
			return "Keychain error: \(status)"
		case .duplicateItem:
			return "Аккаунт уже существует"
		case .itemNotFound:
			return "Аккаунт не найден"
		case .invalidQuery:
			return "Неверный запрос"
		}
	}
}

struct Account {
	let username: String
	let password: String
}

actor AuthSecureStorage {
	private let service: String
	
	init(service: String) {
		self.service = service
	}
	
	func register(username: String, password: String) throws {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: username,
			kSecValueData as String: password.data(using: .utf8)!,
			kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
		]
		
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status != errSecDuplicateItem else {
			throw KeychainError.duplicateItem
		}
		guard status == errSecSuccess else {
			throw KeychainError.unhandled(status)
		}
	}
	
	func login(username: String) throws -> String {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: username,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status == errSecSuccess,
			  let data = item as? Data,
			  let password = String(data: data, encoding: .utf8) else {
			throw KeychainError.itemNotFound
		}
		return password
	}
	
	func changePassword(username: String, newPassword: String) throws {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: username
		]
		
		let update: [String: Any] = [
			kSecValueData as String: newPassword.data(using: .utf8)!
		]
		
		let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
		guard status == errSecSuccess else {
			throw KeychainError.itemNotFound
		}
	}
	
	func getAllAccounts() throws -> [Account] {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecReturnData as String: true,
			kSecReturnAttributes as String: true,
			kSecMatchLimit as String: kSecMatchLimitAll
		]
		
		var items: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &items)
		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw KeychainError.unhandled(status)
		}
		
		guard let itemsArray = items as? [[String: Any]] else {
			return []
		}
		
		return itemsArray.compactMap { item in
			guard let username = item[kSecAttrAccount as String] as? String,
				  let data = item[kSecValueData as String] as? Data,
				  let password = String(data: data, encoding: .utf8) else {
				return nil
			}
			return Account(username: username, password: password)
		}
	}
	
	func deleteAccount(username: String) throws {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: username
		]
		
		let status = SecItemDelete(query as CFDictionary)
		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw KeychainError.unhandled(status)
		}
	}
}
