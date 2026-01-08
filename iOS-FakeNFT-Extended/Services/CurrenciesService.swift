//
//  CurrenciesServiceProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.01.2026.
//


protocol CurrenciesServiceProtocol: Sendable {
	func get() async -> [CurrencyContainer]
	func set(_ currencies: [CurrencyContainer]) async
	
	func performUpdatesIfNeeded() async throws
}

actor CurrenciesService: CurrenciesServiceProtocol {
	private let api: ObservedNetworkClient
	private let storage: CurrenciesStorageProtocol
	
	init(api: ObservedNetworkClient) {
		self.api = api
		self.storage = CurrenciesStorage()
	}
}

// MARK: - CurrenciesService Extensions
// --- methods ---
extension CurrenciesService {
	func get() async -> [CurrencyContainer] {
		await storage.get()
	}
	
	func set(_ currencies: [CurrencyContainer]) async {
		await storage.set(currencies)
	}
	
	func performUpdatesIfNeeded() async throws {
		let rawCurrencies = try await api.getCurrencies()
		let currentCurrencies = await get()
		
		let currentTitles = currentCurrencies.map(\.currency.title).sorted()
		let newTitles = rawCurrencies.map(\.title).sorted()
		
		guard currentTitles != newTitles else { return }
		
		let currencyIDs = Set(rawCurrencies.map(\.id))
		
		let containers = try await withThrowingTaskGroup(
			of: CurrencyContainer?.self,
			returning: [CurrencyContainer].self
		) { group in
			for id in currencyIDs {
				group.addTask(priority: .medium) {
					let currency = try await self.api.getCurrency(by: id)
					return CurrencyContainer(currency: currency, id: id)
				}
			}
			
			var results = [CurrencyContainer]()
			for try await container in group {
				if let container {
					results.append(container)
				}
			}
			return results.sorted { $0.id < $1.id }
		}
		
		await set(containers)
	}
}
