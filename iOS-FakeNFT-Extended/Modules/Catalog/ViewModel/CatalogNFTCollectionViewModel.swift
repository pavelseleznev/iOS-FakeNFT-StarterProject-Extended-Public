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
    private(set) var nfts: [NFTModel] = [
        .mock, .mock, .badImageURLMock, .badImageURLMock, .mock, .mock,
        .mock, .mock, .badImageURLMock, .badImageURLMock, .mock, .mock
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
}
