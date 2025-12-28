//
//  Page.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


enum Page: Identifiable {
	case nftDetail(
		model: NFTModelContainer,
		authorID: String,
		authorWebsiteURLString: String
	)
	
	case onboarding
	case splash
	case tabView
	case aboutAuthor(urlString: String)
	
	// statistics
	case statNFTCollection(
		nftsIDs: [String],
		authorID: String,
		authorWebsiteURLString: String
	)
	case statProfile(profile: UserListItemResponse)
	
	// cart
	case paymentMethodChoose
	case successPayment
	
	var id: String { .init(describing: self) }
	
	var hasNotBackButton: Bool {
		switch self {
		case .splash, .tabView, .successPayment, .onboarding:
			true
		default:
			false
		}
	}
}

extension Page: Hashable {
	static func == (lhs: Page, rhs: Page) -> Bool {
		lhs.hashValue == rhs.hashValue
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
