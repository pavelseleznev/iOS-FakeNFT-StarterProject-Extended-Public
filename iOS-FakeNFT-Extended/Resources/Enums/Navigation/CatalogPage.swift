//
//  CatalogPage.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 07.01.2026.
//


enum CatalogPage {
    case catalogDetails(catalog: NFTCollectionItemResponse)
}

extension CatalogPage: CustomDebugStringConvertible {
	var debugDescription: String {
		switch self {
		case .catalogDetails(let catalog):
			"catalogDetails"
		}
	}
}
