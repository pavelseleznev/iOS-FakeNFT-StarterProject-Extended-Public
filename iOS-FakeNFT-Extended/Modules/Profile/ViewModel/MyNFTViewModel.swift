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
    
    var visibleItems: [NFTResponse] {
        items.sorted(by: itemsSortComparator)
    }
    
    private(set) var isLoading = false
    private(set) var sortOption: ProfileSortActionsViewModifier.SortOption = .name
    
    private let appContainer: AppContainer
    private var items: [NFTResponse] = []
    
    init(
        appContainer: AppContainer,
        items: [NFTResponse] = [],
        sortOption: ProfileSortActionsViewModifier.SortOption = .name
    ) {
        self.appContainer = appContainer
        self.sortOption = sortOption
        self.items = items
    }
    
    func setLoading(_ value: Bool) {
        isLoading = value
    }
    
    func setSortOption(_ option: ProfileSortActionsViewModifier.SortOption) {
        sortOption = option
    }
    
    func loadPurchasedNFTs() async {
        setLoading(true)
        defer { setLoading(false) }
        
        let ids = Array(await appContainer.purchasedNFTsService.get())
        guard !ids.isEmpty else {
            items = []
            return
        }
        
        do {
            items = try await fetchNFTs(ids: ids)
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
    
    private func itemsSortComparator(
        _ first: NFTResponse,
        _ second: NFTResponse
    ) -> Bool {
        switch sortOption {
        case .name:
            first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
        case .cost:
            first.price < second.price
        case .rate:
            first.rating > second.rating
        }
    }
}
