//
//  StatisticsPage.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.01.2026.
//


enum StatisticsPage {
	case nftCollection(
		nftsIDs: [String],
		authorID: String,
		authorWebsiteURLString: String
	)
	case profile(profile: UserListItemResponse)
	
	var debugDescription: String {
		switch self {
		case .nftCollection:
			"nftCollection"
		case .profile:
			"profile"
		}
	}
}
