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
    
    private var collections: [NFTCollectionItemResponse] = [
        .mock1,
        .mock2,
        .mock3
    ]
    
    private let api: ObservedNetworkClient
    private let push: (Page) -> Void
    
    var currentSortOption: SortOption = .name
    
    init(
        api: ObservedNetworkClient,
        push: @escaping (Page) -> Void
    ) {
        self.api = api
        self.push = push
    }
}

extension CatalogViewModel {
    
    var visibleCollections: [NFTCollectionItemResponse] {
        collections.sorted(by: collectionsSortComparator)
    }
    
    func didSelectItem(_ item: NFTCollectionItemResponse) {
        push(.catalogDetails(nftsIDs: item.nftsIDs))
    }
    
    @Sendable
    func loadCollections() async {
        do {
            try await api.getCollections()
        } catch {
            print(error)
        }
    }
    
    func setSortOption(_ option: SortOption) {
        currentSortOption = option
    }
}

private extension CatalogViewModel {
    
    func collectionsSortComparator(
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
