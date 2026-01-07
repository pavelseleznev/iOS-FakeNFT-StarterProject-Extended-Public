//
//  SplashBackgroundView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

fileprivate let backgroundColors: [Color] = [.ypWhite, .clear]

struct SplashBackgroundView: View {
	var body: some View {
		ZStack {
			InfiniteCarouseTimelinelView(
				topfirst: .init(direction: .leftToRight, speed: 0.1),
				topSecond: .init(direction: .rightToLeft, speed: 0.3),
				topThird: .init(direction: .leftToRight, speed: 0.2),
				bottomFirst: .init(direction: .rightToLeft, speed: 0.2),
				bottomSecond: .init(direction: .leftToRight, speed: 0.3),
				bottomThird: .init(direction: .rightToLeft, speed: 0.1)
			)
			
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

#if DEBUG
#Preview {
	SplashBackgroundView()
}
#endif
