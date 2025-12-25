//
//  Page.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


enum Page: Identifiable {
	case splash
	case tabView
	case aboutAuthor(urlString: String)
	
	// statistics
	case statNFTCollection(nftsIDs: [String])
	case statProfile(profile: UserListItemResponse)
	
	// cart
	case paymentMethodChoose
	case successPayment
	
	var id: String { .init(describing: self) }
}

extension Page: Hashable {
	static func == (lhs: Page, rhs: Page) -> Bool {
		lhs.hashValue == rhs.hashValue
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
