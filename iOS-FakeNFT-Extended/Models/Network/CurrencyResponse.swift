//
//  WalletResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import Foundation

struct CurrencyResponse: Decodable, Equatable {
	let title: String
	let name: String
	let image: String
	let id: String
	
	static var mock: Self {
		.init(
			title: "Bitcoin",
			name: "BTC",
			image: "",
			id: UUID().uuidString
		)
	}
}

struct CurrencyContainer: Identifiable, Equatable {
	let currency: CurrencyResponse
	let id: String
}
