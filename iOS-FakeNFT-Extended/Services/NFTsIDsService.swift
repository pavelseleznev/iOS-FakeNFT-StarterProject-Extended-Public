//
//  NFTsIDsService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

import Foundation

enum NFTsIDsKind {
	case order
	case favorites
	case purchased
	
	var userDefaultsKey: String {
		switch self {
		case .order:
			"nfts.order.IDs"
		case .favorites:
			"nfts.favorites.IDs"
		case .purchased:
			"nfts.purchased.IDs"
		}
	}
	
	var notificationName: Notification.Name {
		switch self {
		case .order:
			.cartDidUpdate
		case .favorites:
			.favouritesDidUpdate
		case .purchased:
			.purchasedDidUpdate
		}
	}
}

protocol NFTsIDsServiceProtocol: Sendable {
	func performUpdatesIfNeeded(with loadedIDs: [String]) async
	
	@Sendable
	func get() async -> Set<String>
	
	func loadAndSave() async throws
	
	func contains(_ id: String) async -> Bool
	
	func replace<S: Sequence & Sendable>(withLoaded ids: S) async where S.Element == String
	
	func add(_ id: String) async throws
	
	func remove(_ id: String) async throws
	func removeAll() async
}

actor NFTsIDsService: NFTsIDsServiceProtocol {
	private let api: ObservedNetworkClient
	private let storage: NFTsIDsStorageProtocol
	private let kind: NFTsIDsKind
	
	init(
		api: ObservedNetworkClient,
		kind: NFTsIDsKind
	) {
		self.api = api
		self.storage = NFTsIDsStorage(kind: kind)
		self.kind = kind
	}
}

extension NFTsIDsService {
	func performUpdatesIfNeeded(with loadedIDs: [String]) async {
		let currentIDs = await get()
		let loadedIDs = Set(loadedIDs)
		
		guard currentIDs != loadedIDs else { return }
		
		await replace(withLoaded: loadedIDs)
	}
	
	@Sendable
	func get() async -> Set<String> {
		await storage.get()
	}
	
	func loadAndSave() async throws {
		let updates: [String]
		
		switch kind {
		case .favorites:
			updates = try await api.getProfile().likes
		case .order:
			updates = try await api.getOrder().nftsIDs
		case .purchased:
			updates = try await api.getProfile().nfts
		}
		
		await replace(withLoaded: updates)
		print("NFTsIDsService \(kind) \(#function) success with \(updates)")
	}
	
	func contains(_ id: String) async -> Bool {
		await storage.get().contains(id)
	}
	
	func add(_ id: String) async throws {
		await storage.add(id)
		
		let newIDs = Array(await get().union([id]))
		
		switch kind {
		case .order:
			try await api.putOrder(payload: .init(nfts: newIDs))
		case .favorites:
			try await api.updateProfile(payload: .init(likes: newIDs))
		default:
			break
		}
	}
	
	func replace<S: Sequence & Sendable>(withLoaded ids: S) async where S.Element == String {
		await storage.replaceIDs(withLoaded: ids)
	}
	
	// only like or cart item might be removed
	func remove(_ id: String) async throws {
		guard [.order, .favorites].contains(kind) else { return }
		
		await storage.remove(id)
		
		let newIDs = Array(await get().subtracting([id]))
		let formatted = newIDs.isEmpty ? nil : newIDs
		
		switch kind {
		case .order:
			try await api.putOrder(payload: .init(nfts: formatted))
		case .favorites:
			try await api.updateProfile(payload: .init(likes: formatted))
		default:
			break
		}
	}
	
	// only order might by clear
	func removeAll() async {
		guard case .order = kind else { return }
		await storage.clear()
	}
}
