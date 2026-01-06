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
	}
	
	private var content: some View {
		HStack(spacing: 0) {
			ForEach(0..<5) { index in
				Image.starFill
					.foregroundStyle(
						index < (rating ?? 0) ?
						Color(uiColor: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)) :
						.ypBackgroundUniversal.opacity(0.3)
					)
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
	VStack {
		RatingPreview(rating: 3)
			.scaleEffect(5)
			.frame(height: 100)
		
		VStack(alignment: .leading) {
			Text("Bla bla bla")
				.font(.bold22)
			RatingPreview(rating: 3)
		}
		.padding()
		.background(.ypLightGrey)
		.clipShape(.capsule)
	}
}
#endif
