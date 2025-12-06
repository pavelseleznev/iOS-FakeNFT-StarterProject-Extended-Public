//
//  NetworkObserver.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import Observation

struct RemoveThisAnyDecodableDummy: Decodable {}

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

	init(api: NetworkClient = DefaultNetworkClient()) {
		self.api = api
	}

	func getCollections() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetCollectionRequest()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	func getCollection(by id: String) async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetCollectionByIDRequest(id: id)
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	
	func getNFTs() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetNFTsRequest()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	func getNFT(by id: String) async throws -> NFT {
		let request: NetworkRequest = GetNFTByIDRequest(id: id)
		
		let result: NFT = try await fetch(request)
		return result
	}
	
	func getCurrencies() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetCurrenciesRequest()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	func getCurrency(by id: String) async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetCurrencyByIDRequest(id: id)
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	
	func getOrder() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetOrderRequest()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}

	func orderSetConcurrencyBeforePayment() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetOrderSetConcurrencyBeforePaymentRequest()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	func putOrderAndPay() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = PutOrderAndPayRequest()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	
	func getProfile() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = PutLikesNamePhoto()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	
	func setLikesNamePhoto() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = PutLikesNamePhoto()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	
	func getUsers() async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetUsersRequest()
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	
	func getUser(by id: String) async throws -> RemoveThisAnyDecodableDummy {
		let request: NetworkRequest = GetUserByIDRequest(id: id)
		
		let result: RemoveThisAnyDecodableDummy = try await fetch(request)
		return result
	}
	
	private func fetch<T: Decodable & Sendable>(_ request: NetworkRequest) async throws -> T {
		try await loader.fetchData {
			try await self.api.send(T.self, request: request)
		}
	}
}

