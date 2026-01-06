//
//  Constants.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 27.12.2025.
//

import SwiftUI

enum Constants {
	static let userDataKeychainService = "com.fakeNFT.auth"
	
	static let currenciesStorageKey = "currenciesStorageKey"
	
	static let nftChangePayloadKey = "nftChangePayloadKey"
	
	static let isAuthedKey = "isAuthedKey"
	static let isOnboardingCompleteKey = "isOnboardingCompleteKey"
	static let appLaunchCountKey = "appLaunchCountKey"
	static let ratingIsAlreadyPresentedThisLaunchKey = "ratingIsAlreadyPresentedThisLaunchKey"
	
	static let splashInfiniteCarouselSpeedRatio: CGFloat = 0.05
	static let safeAreaHorizontalPadding: CGFloat = 15
	static let onboardingCellSize: CGFloat = 100
	static let tabIndicatorHeight: CGFloat = 4
	
	static let nftNameLineLimit = 2
	static let authorNameLineLimit = 2
	
	static let defaultAnimation: Animation = .easeInOut(duration: 0.25)
	
	static let maxRatingStars = 5
	
	static let imageCacheOnMemoryWarningOldestCountRemoval = 100
	static let imageCacheCountLimit = 300
	static let imageCacheTotalCostLimit = 75 * 1024 * 1024 // 75 MB
	
	static let bgTaskRefreshInterval: TimeInterval = 15 * 60 // 15 mins
	
	static let splashPresentationDuration: Duration = .seconds(1)
}
