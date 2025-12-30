//
//  NFTModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import Foundation

struct NFTModel: Identifiable, Hashable {
	let imageURLString: String
	let name: String
	let author: String
	let cost: String
	let rate: String
	let isFavorite: Bool
	
	let id: String
	
	static var mock: Self {
		.init(
			imageURLString: "https://public.bnbstatic.com/static/content/square/images/21ba7a4483794ab5a1bfb2cf9a3338ab.png",
			name: "Treasure",
			author: "Jhon Snow",
			cost: "1,78 ETH",
			rate: "2.5/5",
			isFavorite: .random(),
			id: UUID().uuidString
		)
	}
	
	static var badImageURLMock: Self {
		.init(
			imageURLString: "",
			name: "Name",
			author: "William",
			cost: "1,78 ETH",
			rate: "4.5/5",
			isFavorite: .random(),
			id: UUID().uuidString
		)
	}
}

extension NFTModel {
    static let mock1 = NFTModel(
        imageURLString: "https://public.bnbstatic.com/static/content/square/images/21ba7a4483794ab5a1bfb2cf9a3338ab.png",
        name: "Lilo",
        author: "John Doe",
        cost: "1,78 ETH",
        rate: "3/5",
        isFavorite: true,
        id: "mock-1"
    )
    
    static let mock2 = NFTModel(
        imageURLString: "https://public.bnbstatic.com/static/content/square/images/21ba7a4483794ab5a1bfb2cf9a3338ab.png",
        name: "Spring",
        author: "John Doe",
        cost: "3,50 ETH",
        rate: "4/5",
        isFavorite: false,
        id: "mock-2"
    )
    
    static let mock3 = NFTModel(
        imageURLString: "https://public.bnbstatic.com/static/content/square/images/21ba7a4483794ab5a1bfb2cf9a3338ab.png",
        name: "April",
        author: "John Doe",
        cost: "2,10 ETH",
        rate: "5/5",
        isFavorite: true,
        id: "mock-3"
    )
}

extension NFTModel {
    static var preview: NFTModel {
        NFTModel(
            imageURLString: "https://public.bnbstatic.com/static/content/square/images/21ba7a4483794ab5a1bfb2cf9a3338ab.png",
            name: "April",
            author: "John Doe",
            cost: "2,10 ETH",
            rate: "5/5",
            isFavorite: true,
            id: UUID().uuidString
        )
    }
}
