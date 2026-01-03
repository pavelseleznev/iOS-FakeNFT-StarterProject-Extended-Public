//
//  InfiniteImagesRollingCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct LoopingScrollCellView: View {
	let item: InfiniteCarouselItem
	
	var body: some View {
		Image(item.resource)
			.resizable()
			.aspectRatio(1, contentMode: .fill)
			.clipShape(
				RoundedRectangle(cornerRadius: Constants.onboardingCellSize / 4)
			)
			.shadow(color: .ypBlack.opacity(0.1), radius: 5)
			.id(item.id)
	}
}

#if DEBUG
#Preview {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		LoopingScrollCellView(item: .init(resource: .onboardingCollect))
	}
}
#endif
