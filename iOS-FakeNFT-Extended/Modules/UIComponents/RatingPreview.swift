//
//  RatingPreview.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct RatingPreview: View {
	let rating: Int?
	
	@Environment(\.colorScheme) private var theme
	
	var body: some View {
		content
			.opacity(rating == nil ? 0 : 1)
			.overlay {
				if rating == nil {
					LoadingShimmerPlaceholderView()
				}
			}
			.font(.startIcon)
			.shadow(
				color: shadowColor,
				radius: 1
			)
	}
	
	private var content: some View {
		HStack(spacing: 0) {
			ForEach(0..<5) { index in
				Image.starFill
					.foregroundStyle(index < (rating ?? 0) ? .ypYellowUniversal : .ypLightGrey)
			}
		}
	}
	
	private var shadowColor: Color {
		if theme == .dark {
			.ypYellowUniversal.opacity(0.8)
		} else {
			.ypBlackUniversal.opacity(0.4)
		}
	}
}

#if DEBUG
#Preview {
	RatingPreview(rating: 3)
		.scaleEffect(5)
}
#endif
