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
    
    private let service: ProfileService
    
    init(items: [NFTModel], service: ProfileService) {
        self.items = items
        self.service = service
    }
    
    func removeLocal(id: String) -> [NFTModel] {
        let old = items
        items.removeAll { $0.id == id }
        return old
    }
    
    func syncLikesToServer() async throws {
        try await service.updateLikes(items.map(\.id))
    }
    
    func restore(_ oldItems: [NFTModel]) {
        items = oldItems
    }
}
