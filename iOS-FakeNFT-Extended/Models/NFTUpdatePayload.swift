//
//  NFTUpdatePayload.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import Foundation

struct NFTUpdatePayload {
	enum ObjectType: String, Codable {
		case sellerNFTs, nftDetail
	}
	
	let id: String
	let screenID: UUID
	let updatesID: UUID
	let isCartChanged: Bool
	let isFavoriteChanged: Bool
	let fromObject: ObjectType
	
	var hasChanges: Bool {
		isCartChanged || isFavoriteChanged
	}
}
