//
//  UserListItemResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import Foundation

struct UserListItemResponse: Decodable, Identifiable, Hashable {
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
	
	static var mock: Self {
		.init(
			name: "Jacob Rodriquez",
			avatarURLString: "https://avatars.mds.yandex.net/get-shedevrum/14810012/img_dc6143fba35211efbf2f463786c64669/orig",
			description: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.",
			websiteURLString: "https://practicum.yandex.ru/algorithms/",
			nftsIDs: [
				"1fda6f0c-a615-4a1a-aa9c-a1cbd7cc76ae",
				"77c9aa30-f07a-4bed-886b-dd41051fade2",
				"b3907b86-37c4-4e15-95bc-7f8147a9a660",
				"f380f245-0264-4b42-8e7e-c4486e237504",
				"9810d484-c3fc-49e8-bc73-f5e602c36b40",
				"c14cf3bc-7470-4eec-8a42-5eaa65f4053c",
				"b2f44171-7dcd-46d7-a6d3-e2109aacf520",
				"e33e18d5-4fc2-466d-b651-028f78d771b8",
				"db196ee3-07ef-44e7-8ff5-16548fc6f434",
				"e8c1f0b6-5caf-4f65-8e5b-12f4bcb29efb",
				"739e293c-1067-43e5-8f1d-4377e744ddde",
				"d6a02bd1-1255-46cd-815b-656174c1d9c0",
				"de7c0518-6379-443b-a4be-81f5a7655f48",
				"82570704-14ac-4679-9436-050f4a32a8a0"
			],
			rating: String((1...5).randomElement() ?? 1),
			id: UUID().uuidString
		)
	}
}
