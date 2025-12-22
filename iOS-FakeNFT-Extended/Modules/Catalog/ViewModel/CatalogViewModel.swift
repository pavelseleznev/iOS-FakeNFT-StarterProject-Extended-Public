//
//  CatalogViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 22.12.2025.
//

import Foundation

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var collections: [NFTCollectionItemResponse] = [
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
}
