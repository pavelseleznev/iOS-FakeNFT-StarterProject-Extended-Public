//
//  NotifcationsNames.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import Foundation

extension Notification.Name {
	static let authStateChanged = Notification.Name("authStateChanged")
	
	static let nftDidChange = Notification.Name("nftDidChange")
	
	static let cartDidUpdate = Notification.Name("cartDidUpdate")
	static let favouritesDidUpdate = Notification.Name("favoritesDidUpdate")
	static let purchasedDidUpdate = Notification.Name("purchasedDidUpdate")
	static let currenciesDidUpdate = Notification.Name("currenciesDidUpdate")
	static let profileDidUpdate = Notification.Name("profileDidUpdate")
}
