//
//  Page.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


enum Page: Identifiable {
	case tabView
    case aboutAuthor(urlString: String)
	
    // statistics
    case statNFTCollection(nfts: [NFTModel])
    case statProfile(profile: UserListItemResponse)
    case editProfile(ProfileModel)
    
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
