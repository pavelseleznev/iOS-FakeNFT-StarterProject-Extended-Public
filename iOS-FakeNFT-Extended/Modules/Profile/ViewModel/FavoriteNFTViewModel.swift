//
//  FavoriteNFTViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/23/25.
//

import Foundation

@MainActor
@Observable
final class FavoriteNFTViewModel {
    var items: [NFTModel]
    var count: Int { items.count }
    var loadErrorPresented = false
    var loadErrorMessage = "Не удалось удалить NFT из избранного"
    
    private let service: ProfileService
    
    init(items: [NFTModel], service: ProfileService) {
        self.items = items
        self.service = service
    }
    
    func removeFromFavorites(id: String) async {
        let oldItems = items
        items.removeAll() { $0.id == id }
        
        do {
            try await service.updateLikes(items.map(\.id))
        } catch is CancellationError {
            return
        } catch {
            items = oldItems
            loadErrorMessage = "Не удалось удалить NFT из избранного"
            loadErrorPresented = true
        }
    }
}
