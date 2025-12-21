//
//  NetworkObserver.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import Observation

@MainActor
@Observable
final class ObservedNetworkClient {
	private var loader = DataLoader()
	private let api: NetworkClient
	
	@inlinable
	var loadingState: LoadingState {
		loader.loadingState
	}
	
	func resetLoadingState() {
		loader.resetState()
	}
	
	func setLoadingStateFromWebsite(_ state: LoadingState) {
		loader.setLoadingStateFromWebsite(state)
	}

	init(api: NetworkClient = DefaultNetworkClient()) {
		self.api = api
	}
	
	static let mock = ObservedNetworkClient(api: DefaultNetworkClient())
}

// MARK: - ObservedNetworkClient Extensions

// --- private helpers ---
private extension ObservedNetworkClient {
	func fetch<T: Decodable & Sendable>(_ request: NetworkRequest) async throws -> T {
		try await loader.fetchData {
			try await self.api.send(T.self, request: request)
		}
	}
}

// --- nft collections ---
extension ObservedNetworkClient {
	func getCollections() async throws -> [NFTCollectionItemResponse] {
		let request = GetCollectionRequest()
		return try await fetch(request)
	}
	
	func getCollection(by id: String) async throws -> NFTCollectionItemResponse {
		let request = GetCollectionByIDRequest(id: id)
		return try await fetch(request)
	}
}

// --- nft ---
extension ObservedNetworkClient {
	func getNFTs() async throws -> [NFTResponse] {
		let request = GetNFTsRequest()
		return try await fetch(request)
	}
	
	func getNFT(by id: String) async throws -> NFTResponse {
		let request = GetNFTByIDRequest(id: id)
		return try await fetch(request)
	}
}

// --- currencies ---
extension ObservedNetworkClient {
	func getCurrencies() async throws -> [CurrencyResponse] {
		let request = GetCurrenciesRequest()
		return try await fetch(request)
	}
	
	func getCurrency(by id: String) async throws -> CurrencyResponse {
		let request = GetCurrencyByIDRequest(id: id)
		return try await fetch(request)
	}
}

// --- order ---
extension ObservedNetworkClient {
	@discardableResult
	func putOrderAndPay(payload: OrderPayload) async throws -> OrderRepsonse {
		let request = PutOrderAndPayRequest(payload: payload)
		return try await fetch(request)
	}
	
	func getOrder() async throws -> OrderRepsonse {
		let request = GetOrderRequest()
		return try await fetch(request)
	}
}

// --- profile ---
extension ObservedNetworkClient {
	func getProfile() async throws -> ProfileResponse {
		let request = GetProfileRequest()
		return try await fetch(request)
	}
	
	@discardableResult
	func updateProfile(payload: ProfilePayload) async throws -> ProfileResponse {
		let request = UpdateProfileRequest(payload: payload)
		return try await fetch(request)
	}
}

// --- users ---
extension ObservedNetworkClient {
	func getUsers(page: Int) async throws -> [UserListItemResponse] {
		let request = GetUsersRequest(page: page)
		return try await fetch(request)
	}
	
	func getUser(by id: String) async throws -> UserListItemResponse {
		let request = GetUserByIDRequest(id: id)
		return try await fetch(request)
	}
}
