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
extension Page: CustomDebugStringConvertible {
	var hasNotBackButton: Bool {
		switch self {
		case .splash, .tabView, .cart(.successPayment), .onboarding, .authorization(.login):
			true
		default:
			false
		}
	}
	
	var debugDescription: String {
		switch self {
		case .splash:
			"splash"
		case .onboarding:
			"onboarding"
		case .authorization(let authorizationPage):
			"authorization(\(authorizationPage))"
		case .tabView:
			"tabView"
		case .nftDetail:
			"nftDetail"
		case .aboutAuthor:
			"aboutAuthor"
		case .cart(let cartPage):
			"cart(\(cartPage))"
		case .statistics(let statisticsPage):
			"statistics(\(statisticsPage.debugDescription))"
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
