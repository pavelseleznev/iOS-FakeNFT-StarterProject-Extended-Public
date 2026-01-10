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
    
	private let service: ProfileServiceProtocol
    private let push: (Page) -> Void
    
    init(
		service: ProfileServiceProtocol,
        push: @escaping (Page) -> Void
    ) {
		self.service = service
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
	}
	
	func load() async {
		profile = await service.get()
	}
}

// --- routing ---
extension ProfileViewModel {
	func myNFTsTapped() {
		let nftsIDs = Set(profile.nftsIDs ?? [])
		push(.profile(.myNFTs(nftsIDs)))
	}
	
	func favoriteNFTsTapped() {
		let nftsIDs = Set(profile.favoritesIDs ?? [])
		push(.profile(.favoriteNFTs(nftsIDs)))
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
