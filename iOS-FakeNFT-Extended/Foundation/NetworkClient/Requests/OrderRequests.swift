//
//  GetCollectionRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


import Foundation

struct OrderPayload: Encodable {
	let nfts: String?
	
	init(nfts: [String]? = nil) {
		self.nfts = nfts?.joined(separator: ",") ?? "null"
	}
}

struct PutOrderAndPayRequest: NetworkRequest {
	let payload: OrderPayload
	
	var httpMethod: HttpMethod = .PUT
	var dto: (any Encodable)? { payload }
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
	}
}

struct GetOrderRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
	}
}
