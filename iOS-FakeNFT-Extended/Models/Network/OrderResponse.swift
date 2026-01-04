//
//  OrderGetRepsonse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

struct OrderResponse: Decodable {
	let nftsIDs: [String]
	let id: String
	
	enum CodingKeys: String, CodingKey {
		case id
		case nftsIDs = "nfts"
	}
}
