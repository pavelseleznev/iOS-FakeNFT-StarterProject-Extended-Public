//
//  UserListItemResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

struct UserListItemResponse: Decodable {
	let name: String
	let avatarURLString: String
	let description: String?
	let websiteURLString: String
	let nftsIDs: [String]
	let rating: String
	let id: String
	
	enum CodingKeys: String, CodingKey {
		case name, description, rating, id
		case avatarURLString = "avatar"
		case websiteURLString = "website"
		case nftsIDs = "nfts"
	}
}
