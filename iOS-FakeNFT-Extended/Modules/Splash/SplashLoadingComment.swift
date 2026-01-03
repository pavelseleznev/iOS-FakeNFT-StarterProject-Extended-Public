//
//  SplashLoadingComment.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import Foundation

enum SplashLoadingComment: String, CaseIterable {
	case phase1, phase2, phase3, phase4, phase5, phase6, phase7, phase8
	
	var title: LocalizedStringResource {
		switch self {
		case .phase1:
			.splashLoadingComment1
		case .phase2:
			.splashLoadingComment2
		case .phase3:
			.splashLoadingComment3
		case .phase4:
			.splashLoadingComment4
		case .phase5:
			.splashLoadingComment5
		case .phase6:
			.splashLoadingComment6
		case .phase7:
			.splashLoadingComment7
		case .phase8:
			.splashLoadingComment8
		}
	}
	
	var next: Self {
		var set = Set(Self.allCases)
		set.remove(self)
		return set.randomElement() ?? .phase1
	}
}
