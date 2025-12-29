//
//  FilterToken.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import Foundation

enum FilterToken: String, CaseIterable, Identifiable {
	case isFavourite
	case isInCart
	case isNotFavourite
	case isNotInCart
	
	var title: LocalizedStringResource {
		switch self {
		case .isFavourite:
			.isFavouriteFilter
		case .isInCart:
			.isInCartFilter
		case .isNotFavourite:
			.isNotFavouriteFilter
		case .isNotInCart:
			.isNotInCartFilter
		}
	}
	
	var contrary: Self {
		switch self {
		case .isFavourite:
			.isNotFavourite
		case .isInCart:
			.isNotInCart
		case .isNotFavourite:
			.isFavourite
		case .isNotInCart:
			.isInCart
		}
	}
	
	var id: String { rawValue }
}
