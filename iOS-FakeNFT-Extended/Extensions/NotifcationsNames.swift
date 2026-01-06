//
//  NotifcationsNames.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import Foundation

extension Notification.Name {
	static let nftDidChange = Notification.Name("nftDidChange")
	static let cartDidUpdate = Notification.Name("cartDidUpdate")
	static let favoritesDidUpdate = Notification.Name("favoritesDidUpdate")
	static let purchasedDidUpdate = Notification.Name("purchasedDidUpdate")
	static let currentUserDidUpdate = Notification.Name("currentUserDidUpdate")
	static let authStateChanged = Notification.Name("authStateChanged")
}
