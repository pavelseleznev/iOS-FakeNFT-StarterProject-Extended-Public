//
//  GetCollectionRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


import Foundation

struct GetCollectionRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct GetCollectionByIDRequest: NetworkRequest {
	let id: String
	
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
	}
}

struct GetNFTsRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct GetNFTByIDRequest: NetworkRequest {
	let id: String
	
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
	}
}

struct GetCurrenciesRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct GetCurrencyByIDRequest: NetworkRequest {
	let id: String
	
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/currency/\(id)")
	}
}

struct GetOrderRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct GetOrderSetConcurrencyBeforePaymentRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct PutOrderAndPayRequest: NetworkRequest {
	var httpMethod: HttpMethod = .put
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct GetProfileRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct PutLikesNamePhoto: NetworkRequest {
	var httpMethod: HttpMethod = .put
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct GetUsersRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)")
	}
}

struct GetUserByIDRequest: NetworkRequest {
	let id: String
	
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/user/\(id)")
	}
}
