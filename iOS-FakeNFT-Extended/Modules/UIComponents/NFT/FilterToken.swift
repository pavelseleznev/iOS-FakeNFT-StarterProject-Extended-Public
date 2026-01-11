//
//  FilterToken.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import Foundation

enum FilterToken: Int, CaseIterable, Identifiable {
	case isFavourite
	case isInCart
	case isNotFavourite
	case isNotInCart
	
	case ratingAscending
	case ratingDescending
	case costAscending
	case costDescending
	
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
			
		case .costAscending:
			.costAscending
		case .costDescending:
			.costDescending
		case .ratingAscending:
			.ratingAscending
		case .ratingDescending:
			.ratingDescending
		}
	}
	
	var isSortOption: Bool {
		switch self {
		case .ratingAscending, .ratingDescending, .costAscending, .costDescending:
			true
		default:
			false
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
		
		case .costAscending:
			.costDescending
		case .costDescending:
			.costAscending
		case .ratingAscending:
			.ratingDescending
		case .ratingDescending:
			.ratingAscending
		}
	}
	
	var id: Int { rawValue }
}
