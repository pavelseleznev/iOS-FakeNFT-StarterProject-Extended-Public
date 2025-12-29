//
//  NFTModelContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 21.12.2025.
//


struct NFTModelContainer: Identifiable {
	let nft: NFTResponse
	let isFavorite: Bool
	let isInCart: Bool
	var id: String { nft.id }
}

extension NFTModelContainer {
	static var mock: Self {
		.init(
			nft: .mock,
			isFavorite: .random(),
			isInCart: .random()
		)
	}
	
	static var badImageURLMock: Self {
		.init(
			nft: .badImageURLMock,
			isFavorite: .random(),
			isInCart: .random()
		)
	}
}

extension NFTModelContainer: Hashable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
