//
//  NftDetailState.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//


enum NFTDetailState {
    case initial, loading, failed(Error), data(NFTResponse)
}
