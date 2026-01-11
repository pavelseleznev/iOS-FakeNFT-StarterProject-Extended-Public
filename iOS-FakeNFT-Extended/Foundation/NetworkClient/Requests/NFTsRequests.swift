//
//  GetNFTsRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.12.2025.
//

import Foundation

struct GetNFTsRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/nft")
	}
}

struct GetNFTByIDRequest: NetworkRequest {
	let id: String
	
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
	}
}
