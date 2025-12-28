//
//  SplashLoadingComment.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import Foundation

enum SplashLoadingComment: String, CaseIterable {
	case phase1, phase2, phase3, phase4
	
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
		}
	}
	
	var next: Self {
		switch self {
		case .phase1:
			.phase2
		case .phase2:
			.phase3
		case .phase3:
			.phase4
		case .phase4:
			.phase1
		}
	}
}
