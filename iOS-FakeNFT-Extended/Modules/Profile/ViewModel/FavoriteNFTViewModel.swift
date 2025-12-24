//
//  FavoriteNFTViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/23/25.
//

import Foundation

@Observable
final class FavoriteNFTViewModel {
    var items: [NFTModel]
    var count: Int { items.count }
    
    init(items: [NFTModel]) {
        self.items = items
    }
    
    func removeFavorite(id: String) {
        items.removeAll { $0.id == id }
    }
}
