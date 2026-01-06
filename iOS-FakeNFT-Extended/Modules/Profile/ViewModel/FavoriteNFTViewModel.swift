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
    
    private let appContainer: AppContainer
    
    init(appContainer: AppContainer, items: [NFTModel] = []) {
        self.appContainer = appContainer
        self.items = items
    }
    
    func setItems(_ newItems: [NFTModel]) {
        items = newItems
    }
    
    func setLoading(_ value: Bool) {
        isLoading = value
    }
    
    func loadFavorites() async {
        setLoading(true)
        defer { setLoading(false) }
        
        let ids = Array(await appContainer.nftService.favouritesService.get())
        
        guard !ids.isEmpty else {
            setItems([])
            return
        }
        
        do {
            let dtos = try await fetchNFTs(ids: ids)
            let models = dtos.map(mapToNFTModel(isFavorite: true))
            setItems(models)
        } catch {
            guard !error.isCancellation else { return }
            loadErrorMessage = "Не удалось загрузить избранные NFT"
            loadErrorPresented = true
            print("FavoriteNFT load failed:", (error))
        }
    }
    func updateLikes(_ ids: [String]) async throws {
        let likesPayload: [String?] = ids.isEmpty ? ["null"] : ids.map(Optional.some)
        _ = try await appContainer.api.updateProfile(payload: .init(likes: likesPayload))
    }
    
    func removeFromFavorites(id: String) async {
        let oldItems = items
        items.removeAll() { $0.id == id }
        do {
            try await updateLikes(items.map(\.id))
            
            try await appContainer.nftService.favouritesService.loadAndSave()
        } catch is CancellationError {
            return
        } catch {
            items = oldItems
            loadErrorMessage = "Не удалось удалить NFT из избранного"
            loadErrorPresented = true
        }
    }
    
    func clearAllFavorites() async {
        do {
            _ = try await appContainer.profileService.update(with: ProfilePayload(likes: [nil])
            )
            
            try await appContainer.nftService.favouritesService.loadAndSave()
        } catch {
            guard !error.isCancellation else { return }
            loadErrorMessage = "Не удалось очистить избранное"
        }
    }
    
    private func fetchNFTs(ids: [String]) async throws -> [NFTResponse] {
        try await withThrowingTaskGroup(of: (Int, NFTResponse).self) { group in
            for (index, id) in ids.enumerated() {
                group.addTask { [appContainer] in
                    let dto = try await appContainer.api.getNFT(by: id)
                    return (index, dto)
                }
            }
            
            var bucket: [(Int, NFTResponse)] = []
            bucket.reserveCapacity(ids.count)
            
            for try await pair in group { bucket.append(pair) }
            
            // preserve original ids order
            return bucket.sorted { $0.0 < $1.0 }.map(\.1)
        }
    }
    
    private func mapToNFTModel(isFavorite: Bool) -> (NFTResponse) -> NFTModel {
        { dto in
            NFTModel(
                imageURLString: dto.imagesURLsStrings.first ?? "",
                name: dto.name,
                author: dto.authorSiteURL,
                cost: "\(dto.price) ETH",
                rate: "\(dto.ratingInt)/5",
                isFavorite: isFavorite,
                id: dto.id
            )
        }
    }
}
