//
//  NFTCollectionItemResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import Foundation

struct NFTCollectionItemResponse: Decodable, Identifiable {
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
    
    static var mock: Self {
        .init(
            createdAt: "createdAt",
            name: "Peach",
            coverImageURLString: "coverImageURLString",
            nftsIDs: [],
            description: "description",
            author: "author",
            id: UUID().uuidString
        )
    }
}
