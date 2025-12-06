//
//  Sheet.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


enum Sheet: Hashable, Identifiable {
	case nftDetail(NFTModel)
	
	var id: Self { self }
}
