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
    case catalog(CatalogPage)
    
    var id: String { .init(describing: self)}
}

extension Page: Hashable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ProfilePage {
    case editProfile(ProfileModel)
    case myNFTs
    case favoriteNFTs
}

enum CatalogPage {
    case catalogDetails(catalog: NFTCollectionItemResponse)
}
