//
//  ProfileModelContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.01.2026.
//

struct ProfileContainerModel: Codable, Equatable {
	let name: String?
	let avatarURLString: String?
	let websiteURLString: String?
	let description: String?
	let nftsIDs: [String]?
	let favoritesIDs: [String]?
	
	init(
		name: String? = nil,
		avatarURLString: String? = nil,
		websiteURLString: String? = nil,
		description: String? = nil,
		nftsIDs: [String]? = nil,
		favoritesIDs: [String]? = nil
	) {
		self.name = name
		self.avatarURLString = avatarURLString
		self.websiteURLString = websiteURLString
		self.description = description
		self.nftsIDs = nftsIDs
		self.favoritesIDs = favoritesIDs
	}
	
	init(from model: ProfileResponse) {
		name = model.name
		avatarURLString = model.avatar
		websiteURLString = model.website
		description = model.description
		nftsIDs = model.nfts
		favoritesIDs = model.likes
	}
	
	var anyFieldIsEmpty: Bool {
		if
			let name,
			let avatarURLString,
			let websiteURLString,
			let description,
			let nftsIDs,
			let favoritesIDs
		{
			return name.isEmpty ||
			avatarURLString.isEmpty ||
			websiteURLString.isEmpty ||
			description.isEmpty ||
			nftsIDs.isEmpty ||
			favoritesIDs.isEmpty
		} else {
			return false
		}
	}
}
