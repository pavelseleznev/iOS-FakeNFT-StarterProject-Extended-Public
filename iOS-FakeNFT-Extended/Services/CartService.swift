//
//  CartServiceProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.01.2026.
//

import Foundation

protocol CartServiceProtocol: Sendable {
	func performUpdatesIfNeeded() async throws
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
	func performUpdatesIfNeeded() async throws {
		let newCart = Set(try await api.getOrder().nftsIDs)
		let oldCart = await getCart()
		
		guard newCart != oldCart else { return }
		
		await orderService.replace(withLoaded: newCart)
	}
	
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
			
			try await api.putOrder(payload: .init(nfts: nil))
			await orderService.removeAll()
		} else {
			throw NSError(domain: "PaymentError. Failed to set currency", code: 0, userInfo: nil)
		}
	}
}
