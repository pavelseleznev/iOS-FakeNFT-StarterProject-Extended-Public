//
//  GetCollectionRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.12.2025.
//

import Foundation

struct GetCollectionRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
	}
}

struct GetCollectionByIDRequest: NetworkRequest {
	let id: String
	
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/collections/\(id)")
	}
}
