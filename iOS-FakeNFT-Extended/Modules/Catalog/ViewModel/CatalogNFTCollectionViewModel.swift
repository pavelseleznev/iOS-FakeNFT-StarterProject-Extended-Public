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
    private let push: (Page) -> Void
    
    init(push: @escaping (Page) -> Void) {
        self.push = push
    }
    
    func didTapCollectionAuthor() {
        push(.aboutAuthor(urlString: "https://practicum.yandex.ru"))
    }
}
