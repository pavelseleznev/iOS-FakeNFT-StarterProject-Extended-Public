//
//  NFTCollectionItemResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

struct NFTCollectionItemResponse: Decodable {
	let createdAt: String
	let name: String
	let coverImageURLString: String
	let nftsIDs: [String]
	let description: String
	let author: String
	let id: String
	
	enum CodingKeys: String, CodingKey {
		case createdAt, name, description, author, id
		case coverImageURLString = "cover"
		case nftsIDs = "nfts"
	}
}
