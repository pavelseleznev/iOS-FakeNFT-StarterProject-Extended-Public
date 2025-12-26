//
//  Stretchy.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

extension View {
	func stretchy(isImageFullScreen: Bool) -> some View {
		visualEffect { effect, proxy in
			guard !isImageFullScreen else {
				return effect
					.scaleEffect(
						x: 1,
						y: 1,
						anchor: .bottom
					)
			}
			
			let currentHeight = proxy.size.height
			let scrollOffset = proxy.frame(in: .scrollView).minY
			let positiveOffset = max(0, scrollOffset)
			
			let newHeight = currentHeight + positiveOffset
			let scaleFactor = newHeight / currentHeight
			
			return effect
				.scaleEffect(
					x: scaleFactor,
					y: scaleFactor,
					anchor: .bottom
				)
		}
	}
}
