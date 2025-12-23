//
//  CatalogNFTCollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 23.12.2025.
//

import Foundation

@MainActor
@Observable
final class CatalogNFTCollectionViewModel {
    let nfts: [NFTModel]
    
    init(nfts: [NFTModel]) {
        self.nfts = nfts
    }
}

extension CatalogNFTCollectionViewModel {
    func didTapLikeButton(for nft: NFTModel) {}
    func didTapCartButton(for nft: NFTModel) {}
}
