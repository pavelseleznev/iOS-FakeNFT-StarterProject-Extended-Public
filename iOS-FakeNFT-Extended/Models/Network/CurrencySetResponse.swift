//
//  CurrencySetResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//


struct CurrencySetResponse: Decodable {
	let isSuccess: Bool
	let orderId: String
	let currencyShortName: String
	
	enum CodingKeys: String, CodingKey {
		case isSuccess = "success"
		case orderId
		case currencyShortName = "id"
	}
}