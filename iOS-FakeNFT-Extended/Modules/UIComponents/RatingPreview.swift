//
//  RatingPreview.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct RatingPreview: View {
	let rating: String
	
	var body: some View {
		HStack(spacing: 0) {
			ForEach(0..<5) { index in
				Image.starFill
					.foregroundStyle(index < starsCount ? .ypYellowUniversal : .ypLightGrey)
					.font(.startIcon)
					.shadow(color: .ypYellowUniversal.opacity(0.8), radius: 1)
			}
		}
	}
	
	private var starsCount: Int {
		Int(Double(rating.split(separator: "/")[0]) ?? 0)
	}
}

#if DEBUG
#Preview {
	RatingPreview(rating: "3.5/5")
		.scaleEffect(5)
}
#endif
