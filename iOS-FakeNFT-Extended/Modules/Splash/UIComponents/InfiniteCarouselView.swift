//
//  InfiniteCarouselView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI
import Combine

fileprivate let items: [InfiniteCarouselItem] = [
	.onboardingCollect,
	.onboardingCompete,
	.onboardingExplore,
	.appIconSmall,
	.successPurchase,
	.big,
	.coverCollectionBig
].compactMap { .init(resource: $0) }

struct InfiniteCarouselView: View {
	let direction: InfiniteCarouseDirection
	let speed: CGFloat
	
	@State private var timerCancellable: Cancellable?
	@State private var scrollView: UIScrollView?
	
	var body: some View {
		LoopingScrollView(
			items: items.shuffled(),
			spacing: Constants.safeAreaHorizontalPadding,
			width: Constants.onboardingCellSize,
			onScrollViewCreated: { sv in
				scrollView = sv
			}
		) { item in
			LoopingScrollCellView(item: item)
		}
		.scrollDisabled(true)
		.scrollClipDisabled()
		.scrollIndicators(.hidden)
		.contentMargins(
			.horizontal,
			Constants.safeAreaHorizontalPadding,
			for: .scrollContent
		)
		.onAppear(perform: performAutoScroll)
		.onDisappear(perform: clearTimer)
		.frame(height: Constants.onboardingCellSize)
	}
	
	private func performAutoScroll() {
		timerCancellable = Timer
			.publish(
				every: Constants.splashInfiniteCarouselSpeedRatio * speed,
				on: .main,
				in: .common
			)
			.autoconnect()
			.sink { _ in
				scrollToNext()
			}
	}
	
	private func scrollToNext() {
		guard let scrollView else { return }
		
		let currentOffset = scrollView.contentOffset.x
		
		let nextOffset: CGFloat
		switch direction {
		case .leftToRight:
			nextOffset = currentOffset + Constants.onboardingCellSize / 2
		case .rightToLeft:
			nextOffset = currentOffset - Constants.onboardingCellSize / 2
		}
		
		scrollView
			.setContentOffset(
				CGPoint(x: nextOffset, y: 0),
				animated: true
			)
	}
	
	private func clearTimer() {
		timerCancellable?.cancel()
		timerCancellable = nil
	}
}

#if DEBUG
#Preview("InifiniteScrollView") {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		InfiniteCarouselView(direction: .leftToRight, speed: 1)
			.background(.red)
	}
}
#endif
