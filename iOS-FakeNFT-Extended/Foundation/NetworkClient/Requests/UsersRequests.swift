//
//  GetUsersRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.12.2025.
//

import Foundation

struct GetUsersRequest: NetworkRequest {
	let page: Int
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/users?page=\(page)&size=9&sortBy=name,asc")
	}
}

struct GetUserByIDRequest: NetworkRequest {
	let id: String
	
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/users/\(id)")
	}
}
