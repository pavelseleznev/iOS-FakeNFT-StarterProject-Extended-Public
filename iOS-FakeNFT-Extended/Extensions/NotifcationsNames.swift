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
	static let favoritesDidUpdate = Notification.Name("favoritesDidUpdate")
	static let purchasedDidUpdate = Notification.Name("purchasedDidUpdate")
	static let currentUserDidUpdate = Notification.Name("currentUserDidUpdate")

	static let profileNameDidChange = Notification.Name("profileNameDidChange")
	static let profileAvatarDidChange = Notification.Name("profileAvatarDidChange")
	static let profileWebsiteDidChange = Notification.Name("profileWebsiteDidChange")
	static let profileDescriptionDidChange = Notification.Name("profileDescriptionDidChange")
}
