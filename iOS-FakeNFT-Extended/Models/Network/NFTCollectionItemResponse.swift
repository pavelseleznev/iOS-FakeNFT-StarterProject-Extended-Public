//
//  NFTCollectionItemResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import Foundation

struct NFTCollectionItemResponse: Decodable, Identifiable, Equatable {
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
    
    static var mock1: Self {
        .init(
            createdAt: "createdAt",
            name: "Apple",
            coverImageURLString: "coverImageURLString",
            nftsIDs: [
                "d6a02bd1-1255-46cd-815b-656174c1d9c0"
            ],
            description: "description",
            author: "author",
            id: UUID().uuidString
        )
    }
    
    static var mock2: Self {
        .init(
            createdAt: "createdAt",
            name: "Banana",
            coverImageURLString: "coverImageURLString",
            nftsIDs: [
                "d6a02bd1-1255-46cd-815b-656174c1d9c0",
                "f380f245-0264-4b42-8e7e-c4486e237504"
            ],
            description: "description",
            author: "author",
            id: UUID().uuidString
        )
    }
    
    static var mock3: Self {
        .init(
            createdAt: "createdAt",
            name: "Cherry",
            coverImageURLString: "coverImageURLString",
            nftsIDs: [
                "d6a02bd1-1255-46cd-815b-656174c1d9c0",
                "f380f245-0264-4b42-8e7e-c4486e237504",
                "c14cf3bc-7470-4eec-8a42-5eaa65f4053c"
            ],
            description: "description",
            author: "author",
            id: UUID().uuidString
        )
    }
}
