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
    
    var visibleCollections: [NFTCollectionItemResponse] {
		collections
			.sorted(by: collectionsSortComparator)
			.filter {
				$0.name.lowercased().contains(searchText.lowercased()) || searchText.isEmpty
			}
    }
    
    private var collections: [NFTCollectionItemResponse] = []
    
    private let api: ObservedNetworkClient
    private let push: (Page) -> Void
    
    private var currentSortOption: SortOption = .name
	private var searchText = ""
    
    init(
        api: ObservedNetworkClient,
        push: @escaping (Page) -> Void
    ) {
        self.api = api
        self.push = push
    }
}

// MARK: - CatalogViewModel Extensions
// --- helpers ---
extension CatalogViewModel {
	func setSortOption(_ option: SortOption) {
		currentSortOption = option
	}
	
	func onDebounce(_ text: String) {
		searchText = text
	}
	
	func didSelectItem(_ item: NFTCollectionItemResponse) {
		push(.catalog(.catalogDetails(catalog: item)))
	}
	
	func loadCollections() async {
		do {
			collections = try await api.getCollections()
		} catch {
			print(error)
		}
	}
}

// ---- helpers ---
private extension CatalogViewModel {
	func collectionsSortComparator(
		_ first: NFTCollectionItemResponse,
		_ second: NFTCollectionItemResponse
	) -> Bool {
		switch currentSortOption {
		case .name:
			first.name.localizedStandardCompare(second.name) == .orderedAscending
		case .nftCount:
			Set(first.nftsIDs).count > Set(second.nftsIDs).count
		}
	}
}
