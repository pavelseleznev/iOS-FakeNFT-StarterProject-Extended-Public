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
}

protocol NFTsIDsServiceProtocol: Sendable {
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
		self.storage = NFTsIDsStorage(userDefaultsKey: kind.userDefaultsKey)
		self.kind = kind
	}
}

extension NFTsIDsService {
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
		
		switch kind {
		case .order:
			try await api.putOrder(payload: .init(nfts: newIDs))
		case .favorites:
			try await api.updateProfile(payload: .init(likes: newIDs))
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

protocol CatalogServiceProtocol: Sendable {}

protocol StatisticsServiceProtocol: Sendable {
	func getUsers(page: Int) async -> [UserListItemResponse]
	var nftService: NFTServiceProtocol { get }
}



protocol CartServiceProtocol: Sendable {
	func getCart() async -> Set<String>
	func loadCurrencies() async throws -> [CurrencyResponse]
	func loadCurrency(byID id: String) async throws -> CurrencyResponse
	func pay(usingCurrencyID: String) async throws
}

actor CartService: CartServiceProtocol {
	private let orderService: NFTsIDsServiceProtocol
	private let api: ObservedNetworkClient
	
	init(orderService: NFTsIDsServiceProtocol, api: ObservedNetworkClient) {
		self.orderService = orderService
		self.api = api
	}
}

extension CartService {
	func getCart() async -> Set<String> {
		await orderService.get()
	}
	
	func loadCurrencies() async throws -> [CurrencyResponse] {
		try await api.getCurrencies()
	}
	
	func loadCurrency(byID id: String) async throws -> CurrencyResponse {
		try await api.getCurrency(by: id)
	}
	
	func pay(usingCurrencyID id: String) async throws {
		let result = try await api.setCurrency(id: id)
		
		if result.isSuccess {
			for id in await orderService.get() {
				try await api.pay(payload: .init(nfts: id))
			}
			
			await orderService.removeAll()
		} else {
			throw NSError(domain: "PaymentError. Failed to set currency", code: 0, userInfo: nil)
		}
	}
}
