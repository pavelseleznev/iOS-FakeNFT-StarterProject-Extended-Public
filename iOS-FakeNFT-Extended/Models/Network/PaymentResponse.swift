//
//  PaymentResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

struct PaymentResponse: Decodable {
	let success: Bool
	let orderId: String
	let id: String
}
