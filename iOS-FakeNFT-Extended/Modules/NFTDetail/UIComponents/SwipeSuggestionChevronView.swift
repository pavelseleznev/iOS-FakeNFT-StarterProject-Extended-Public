//
//  SwipeSuggestionChevronView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import SwiftUI

struct SwipeSuggestionChevronView: View {
	let isImageFullScreen: Bool
	let screenWidth: CGFloat
	var body: some View {
		Group {
			if isImageFullScreen {
				Image(systemName: "chevron.up")
					.resizable()
					.offset(y: screenWidth * 0.2)
			} else {
				Image(systemName: "chevron.down")
					.resizable()
					.offset(y: screenWidth * 0.9)
			}
		}
		.foregroundStyle(.ypGreenUniversal)
		.blendMode(.difference)
		.symbolEffect(
			.variableColor,
			options: .default,
			isActive: true
		)
		.contentTransition(.symbolEffect(.automatic))
		.frame(width: 32, height: 16)
	}
}
