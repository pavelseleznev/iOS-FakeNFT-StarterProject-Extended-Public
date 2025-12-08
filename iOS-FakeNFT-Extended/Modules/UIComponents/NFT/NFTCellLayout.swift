//
//  NFTCellLayout.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import CoreGraphics

enum NFTCellLayout {
	case my, cart, compact
	
	var imageWidth: CGFloat {
		switch self {
		case .my:
			108
		case .cart:
			108
		case .compact:
			80
		}
	}
	
	var imageHeight: CGFloat {
		switch self {
		case .my:
			108
		case .cart:
			108
		case .compact:
			80
		}
	}
}
