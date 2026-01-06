//
//  Page.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import Foundation

enum Page {
	case splash
	case onboarding
	case authorization(AuthorizationPage)
	case tabView
	
	case nftDetail(
		model: NFTModelContainer,
		authorID: String,
		authorCollection: [Dictionary<String, NFTModelContainer?>.Element],
		authorWebsiteURLString: String
	)
	
	case aboutAuthor(urlString: String)
	
	case cart(CartPage)
	case statistics(StatisticsPage)
}

// MARK: - Page extensions
// --- properties ---
extension Page {
	var hasNotBackButton: Bool {
		switch self {
		case .splash, .tabView, .cart(.successPayment), .onboarding, .authorization(.login):
			true
		default:
			false
		}
	}
}

// --- conformances
extension Page: Identifiable {
	var id: String { "\(self)" }
}

extension Page: Hashable {
	static func == (lhs: Page, rhs: Page) -> Bool {
		lhs.hashValue == rhs.hashValue
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
