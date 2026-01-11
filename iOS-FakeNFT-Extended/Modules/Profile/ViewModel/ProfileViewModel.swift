//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import Foundation

@MainActor
@Observable
final class ProfileViewModel {
	private(set) var profile = ProfileContainerModel()
	private(set) var favoutiresIDs = Set<String>()
	private(set) var purchasedIDs = Set<String>()
    
	private let profileService: ProfileServiceProtocol
	private let favouritesService: NFTsIDsServiceProtocol
	private let purchaseService: NFTsIDsServiceProtocol
    private let push: (Page) -> Void
    
    init(
		profileService: ProfileServiceProtocol,
		favouritesService: NFTsIDsServiceProtocol,
		purchaseService: NFTsIDsServiceProtocol,
        push: @escaping (Page) -> Void
    ) {
		self.profileService = profileService
		self.favouritesService = favouritesService
		self.purchaseService = purchaseService
        self.push = push
    }
}

// MARK: - ProfileViewModel Extensions
// --- updates ---
extension ProfileViewModel {
	func profileDidUpdate(_ notification: Notification) {
		guard
			let value = notification.userInfo?[Constants.profileStorageKey] as? ProfileContainerModel
		else { return }
		
		profile = value
		favoutiresIDs = Set(profile.favoritesIDs ?? [])
		purchasedIDs = Set(profile.nftsIDs ?? [])
	}
	
	func load() async {
		async let profileUpdate = profileService.get()
		async let favouritesUpdate = favouritesService.get()
		async let purchaseUpdate = purchaseService.get()
		
		let (_profile, _fav, _pur) = await (profileUpdate, favouritesUpdate, purchaseUpdate)
		
		profile = _profile
		favoutiresIDs = _fav
		purchasedIDs = _pur
	}
}

// --- routing ---
extension ProfileViewModel {
	func myNFTsTapped() {
		push(.profile(.myNFTs(purchasedIDs)))
	}
	
	func favoriteNFTsTapped() {
		push(.profile(.favoriteNFTs(favoutiresIDs)))
	}
	
	func editTapped() {
		let convertedProfile = ProfilePayload(from: profile)
		push(.profile(.editProfile(convertedProfile)))
	}
	
	func websiteTapped() {
		guard
			let urlString = profile.websiteURLString,
			!urlString.isEmpty
		else { return }
		
		push(.aboutAuthor(urlString: urlString))
	}
}
