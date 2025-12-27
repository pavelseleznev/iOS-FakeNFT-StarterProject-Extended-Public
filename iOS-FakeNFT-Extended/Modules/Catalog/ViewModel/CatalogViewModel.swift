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
    private(set) var collections: [NFTCollectionItemResponse] = [
        .mock,
        .mock,
        .mock,
        .mock,
        .mock,
        .mock,
        .mock,
        .mock,
        .mock
    ]
    
    private let api: ObservedNetworkClient
    private let push: (Page) -> Void
    
    init(
        api: ObservedNetworkClient,
        push: @escaping (Page) -> Void
    ) {
        self.api = api
        self.push = push
    }
    
    func applySortByName() {
        //TODO: Добавить логику сортировки
    }
    
    func applySortByNFTCount() {
        //TODO: Добавить логику сортировки
    }
    
    func didSelectItem(_ item: NFTCollectionItemResponse) {
        //TODO: Добавить логику навигации
    }
}
