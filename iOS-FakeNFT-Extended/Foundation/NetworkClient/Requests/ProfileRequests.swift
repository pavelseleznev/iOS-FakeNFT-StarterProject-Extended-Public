//
//  GetProfileRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.12.2025.
//

import Foundation

struct GetProfileRequest: NetworkRequest {
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
	}
}

struct UpdateProfileRequest: NetworkRequest {
	let payload: ProfilePayload
	
	var httpMethod: HttpMethod = .PUT
	var dto: (any Encodable)? { payload }
	var endpoint: URL? {
		URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
	}
}

struct ProfilePayload: Encodable {
	let name: String?
	let description: String?
	let avatar: String?
	let website: String?
	let likes: [String]?
	
	init(
		name: String? = nil,
		description: String? = nil,
		avatar: String? = nil,
		website: String? = nil,
		likes: [String]? = nil
	) {
		self.name = name
		self.description = description
		self.avatar = avatar
		self.website = website
		self.likes = likes
	}
}
