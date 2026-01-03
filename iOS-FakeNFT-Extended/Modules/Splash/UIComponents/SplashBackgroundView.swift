//
//  SplashBackgroundView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

fileprivate let backgroundColors: [Color] = [.ypWhite, .clear]
fileprivate let spacing: CGFloat = 16

struct SplashBackgroundView: View {
	var body: some View {
		ZStack {
			VStack(spacing: spacing) {
				VStack(spacing: spacing) {
					InfiniteCarouselView(direction: .leftToRight, speed: 0.4)
					InfiniteCarouselView(direction: .rightToLeft, speed: 0.5)
					InfiniteCarouselView(direction: .leftToRight, speed: 0.55)
				}
				
				Spacer(minLength: Constants.onboardingCellSize * 2)
				
				VStack(spacing: spacing) {
					InfiniteCarouselView(direction: .rightToLeft, speed: 0.6)
					InfiniteCarouselView(direction: .leftToRight, speed: 0.5)
					InfiniteCarouselView(direction: .rightToLeft, speed: 0.4)
				}
			}
			.opacity(0.6)
			.blur(radius: 1)
			
			VStack {
				gradientView(colors: backgroundColors)
				Spacer()
				gradientView(colors: backgroundColors.reversed())
			}
			.ignoresSafeArea()
		}
	}
	
	private func gradientView(colors: [Color]) -> some View {
		LinearGradient(
			colors: colors,
			startPoint: .top,
			endPoint: .bottom
		)
	}
}
