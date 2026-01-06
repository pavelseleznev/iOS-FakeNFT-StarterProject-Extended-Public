//
//  CurrenciesStorageProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.01.2026.
//

import Foundation

protocol CurrenciesStorageProtocol: Sendable, AnyObject {
	func get() async -> [CurrencyContainer]
	func set(_ currencies: [CurrencyContainer]) async
}

actor CurrenciesStorage: CurrenciesStorageProtocol {
	private var saveTask: Task<Void, Never>?
	
	private var currencies = [CurrencyContainer]()
	private let userDefaultsKey = Constants.currenciesStorageKey
	private let storage = StorageActor.shared
	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()
	
	init() {
		Task(priority: .userInitiated) {
			await self.restoreFromStorage()
		}
	}
	
	private func restoreFromStorage() async {
		if
			let data: Data = await storage.value(forKey: userDefaultsKey),
			let decoded = try? decoder.decode([CurrencyContainer].self, from: data)
		{
			currencies = decoded
			print("\ncurrencies restored from storage")
		}
	}
	
	private func scheduleSave() {
		saveTask?.cancel()
		saveTask = Task(priority: .background) { @MainActor in
			do {
				try await Task.sleep(for: .seconds(0.5))
				
				guard !Task.isCancelled else { return }
				let encoded = try await encoder.encode(currencies)
				await storage.set(encoded, forKey: userDefaultsKey)
				print("\ncurrencies saved to storage")
			} catch is CancellationError {
				print("\(#file) | \(#function) cancelled")
			} catch {
				print("\(#file) | \(#function) failed to save currencies: \(error.localizedDescription)")
			}
		}
	}
	
	private func sendUpdates() {
		Task(priority: .background) { @MainActor in
			let _currencies = await Array(currencies)
			
			NotificationCenter.default.post(
				name: .currentUserDidUpdate,
				object: nil,
				userInfo: ["currencies" : _currencies]
			)
			
			print("\nupdate notificaiton send for currencies")
		}
	}
}

// MARK: - CurrenciesStorage Extensions
// --- methods ---
extension CurrenciesStorage {
	func get() -> [CurrencyContainer] {
		currencies
	}
	
	func set(_ currencies: [CurrencyContainer]) {
		self.currencies = currencies
		scheduleSave()
	}
}

