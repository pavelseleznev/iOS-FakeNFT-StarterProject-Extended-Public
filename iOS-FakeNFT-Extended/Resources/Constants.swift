//
//  Constants.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 27.12.2025.
//

import SwiftUI

enum Constants {
	static let nftChangePayloadKey = "nftChangePayloadKey"
	
	static let isOnboardingCompleteKey = "isOnboardingCompleteKey"
	static let appLaunchCountKey = "appLaunchCountKey"
	static let ratingIsAlreadyPresentedThisLaunchKey = "ratingIsAlreadyPresentedThisLaunchKey"
	
	static let splashInfiniteCarouselSpeedRatio: CGFloat = 0.05
	static let safeAreaHorizontalPadding: CGFloat = 15
	static let onboardingCellSize: CGFloat = 100
	static let tabIndicatorHeight: CGFloat = 4
	
	static let nftNameLineLimit = 2
	static let authorNameLineLimit = 2
	
	static let defaultAnimation: Animation = .easeInOut(duration: 0.15)
	
	static let maxRatingStars = 5
}
