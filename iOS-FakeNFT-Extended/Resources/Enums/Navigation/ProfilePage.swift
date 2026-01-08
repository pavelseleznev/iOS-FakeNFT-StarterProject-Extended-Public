//
//  ProfilePage.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 07.01.2026.
//


enum ProfilePage {
	case editProfile(ProfilePayload)
    case myNFTs
    case favoriteNFTs
}

extension ProfilePage: CustomDebugStringConvertible {
	var debugDescription: String {
		switch self {
		case .editProfile:
			"editProfile"
		case .myNFTs:
			"myNFTs"
		case .favoriteNFTs:
			"favoriteNFTs"
		}
	}
}
