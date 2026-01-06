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
	
    case statNFTCollection(nfts: [NFTModel])
    case statProfile(profile: UserListItemResponse)
    
    case profile(ProfilePage)
    
    var id: String { .init(describing: self)}
}

extension Page: Hashable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ProfilePage {
    // profile
    case editProfile(ProfileModel)
    case myNFTs
    case favoriteNFTs
}
