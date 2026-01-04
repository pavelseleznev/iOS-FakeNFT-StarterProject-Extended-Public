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
    var isLoading = false
    var count: Int { items.count }
    var loadErrorPresented = false
    var loadErrorMessage = "Не удалось удалить NFT из избранного"
    
    private let api: ObservedNetworkClient
    
    init(items: [NFTModel], api: ObservedNetworkClient) {
        self.items = items
        self.api = api
    }
    
    func setItems(_ newItems: [NFTModel]) {
        items = newItems
    }
    
    func setLoading(_ value: Bool) {
        isLoading = value
    }
    
    func removeFromFavorites(id: String) async {
        let oldItems = items
        items.removeAll() { $0.id == id }
        do {
            try await updateLikes(items.map(\.id))
        } catch is CancellationError {
            return
        } catch {
            items = oldItems
            loadErrorMessage = "Не удалось удалить NFT из избранного"
            loadErrorPresented = true
        }
    }
    
    func updateLikes(_ ids: [String]) async throws {
        let likesPayload: [String?] = ids.isEmpty ? ["null"] : ids.map(Optional.some)
        _ = try await api.updateProfile(payload: .init(likes: likesPayload))
    }
}
