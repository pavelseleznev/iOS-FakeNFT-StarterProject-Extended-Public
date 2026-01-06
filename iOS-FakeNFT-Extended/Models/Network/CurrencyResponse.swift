//
//  WalletResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import Foundation

struct CurrencyResponse: Codable, Hashable {
	let title: String
	let name: String
	let image: String
	let id: String
	
	static var mock: Self {
		.init(
			title: "Bitcoin",
			name: "BTC",
			image: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Bitcoin_(BTC).png",
			id: "BTC"
		)
	}
}

struct CurrencyContainer: Codable, Identifiable, Hashable {
	let currency: CurrencyResponse
	let id: String
}
