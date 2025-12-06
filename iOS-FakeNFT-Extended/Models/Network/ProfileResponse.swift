//
//  ProfileResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

struct ProfileResponse: Decodable {
	let name: String
	let avatar: String
	let description: String
	let website: String
	let nfts: [String]
	let likes: [String]
	let id: String
}
