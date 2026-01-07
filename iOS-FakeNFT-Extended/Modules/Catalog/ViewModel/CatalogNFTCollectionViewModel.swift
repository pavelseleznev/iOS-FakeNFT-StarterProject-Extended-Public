//
//  CatalogNFTCollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 23.12.2025.
//

import Observation

@MainActor
@Observable
final class CatalogNFTCollectionViewModel {
    private let api: ObservedNetworkClient
    private let push: (Page) -> Void
    
    init(
        api: ObservedNetworkClient,
        push: @escaping (Page) -> Void
    ) {
        self.api = api
        self.push = push
    }
    
    func didTapCollectionAuthor() {
        push(.aboutAuthor(urlString: "https://practicum.yandex.ru"))
    }
}
