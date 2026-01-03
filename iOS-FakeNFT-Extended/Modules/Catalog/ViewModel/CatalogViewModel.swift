//
//  CatalogViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 22.12.2025.
//

import Observation

@MainActor
@Observable
final class CatalogViewModel {
    typealias SortOption = CatalogSortActionsViewModifier.SortOption
    
    // MARK: - Public Properties
    
    var visibleCollections: [NFTCollectionItemResponse] {
        collections.sorted(by: collectionsSortComparator)
    }
    
    // MARK: - Private Properties
    
    private var collections: [NFTCollectionItemResponse] = []
    
    private let api: ObservedNetworkClient
    private let push: (Page) -> Void
    
    private var currentSortOption: SortOption = .name
    
    // MARK: - Initializers
    
    init(
        api: ObservedNetworkClient,
        push: @escaping (Page) -> Void
    ) {
        self.api = api
        self.push = push
    }
    
    // MARK: - Public Methods
    
    func didSelectItem(_ item: NFTCollectionItemResponse) {
        push(.catalogDetails(nftsIDs: item.nftsIDs))
    }
    
    @Sendable
    func loadCollections() async {
        do {
            collections = try await api.getCollections()
            print("Gigas \(collections)")
        } catch {
            print(error)
        }
    }
    
    func setSortOption(_ option: SortOption) {
        currentSortOption = option
    }
    
    // MARK: - Private Methods
    
    private func collectionsSortComparator(
        _ first: NFTCollectionItemResponse,
        _ second: NFTCollectionItemResponse
    ) -> Bool {
        switch currentSortOption {
        case .name:
            first.name.localizedStandardCompare(second.name) == .orderedAscending
        case .nftCount:
            first.nftsIDs.count > second.nftsIDs.count
        }
    }
}
