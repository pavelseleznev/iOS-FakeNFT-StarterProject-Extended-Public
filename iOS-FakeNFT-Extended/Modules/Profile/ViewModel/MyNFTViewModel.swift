//
//  MyNFTViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/19/25.
//

import Foundation

@MainActor
@Observable
final class MyNFTViewModel {
    
    var count: Int { items.count }
    private(set) var isLoading = false
    private(set) var items: [NFTModel] = []
    private(set) var sortOption: ProfileSortActionsViewModifier.SortOption = .name
    
    private let appContainer: AppContainer
    
    init(
        appContainer: AppContainer,
        items: [NFTModel] = [],
        sortOption: ProfileSortActionsViewModifier.SortOption = .name
    ) {
        self.appContainer = appContainer
        self.sortOption = sortOption
        setItems(items)
    }
    
    func setItems(_ newItems: [NFTModel]) {
        items = newItems
        applySort()
    }
    
    func setLoading(_ value: Bool) {
        isLoading = value
    }
    
    func setSortOption(_ option: ProfileSortActionsViewModifier.SortOption) {
        sortOption = option
        applySort()
    }
    
    func loadPurchasedNFTs() async {
        setLoading(true)
        defer { setLoading(false) }
        
        let ids = Array(await appContainer.purchasedNFTsService.get())
        guard !ids.isEmpty else {
            setItems([])
            return
        }
        
        do {
            let dtos = try await fetchNFTs(ids: ids)
            let models = dtos.map(mapToNFTModel(isFavorite: false))
            setItems(models)
        } catch {
            guard !error.isCancellation else { return }
            print("MyNFT load failed:", (error))
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
    
    private func applySort() {
        switch sortOption {
        case .name:
            items.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .cost:
            items.sort { value(from: $0.cost) < value(from: $1.cost) }
        case .rate:
            items.sort { ratingValue(from: $0.rate) > ratingValue(from: $1.rate) }
        }
    }
    
    private func value(from costString: String) -> Double {
        let numberPart = costString
            .components(separatedBy: CharacterSet(charactersIn: "0123456789,." ).inverted)
            .joined()
            .replacingOccurrences(of: ",", with: ".")
        return Double(numberPart) ?? 0
    }
    
    private func ratingValue(from rateString: String) -> Double {
        let left = rateString.split(separator: "/").first ?? ""
        return Double(left.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
}
