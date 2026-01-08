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
	
	var myNFTTitle: String { "Мои NFT (\(profile.nftsIDs?.count ?? -1))" } // TODO: Localie
	var favoriteTitle: String { "Избранные NFT (\(profile.favoritesIDs?.count ?? -1))" } // TODO: Localize
}

// --- routing ---
extension ProfileViewModel {
	func myNFTsTapped() {
		push(.profile(.myNFTs))
	}
	
	func favoriteNFTsTapped() {
		push(.profile(.favoriteNFTs))
	}
	
	func editTapped() {
		guard !profile.anyFieldIsEmpty else { return }
		
		push(.profile(.editProfile(.init(from: profile))))
	}
	
	func websiteTapped() {
		guard
			let urlString = profile.websiteURLString,
			!urlString.isEmpty
		else { return }
		
		push(.aboutAuthor(urlString: urlString))
	}
}
