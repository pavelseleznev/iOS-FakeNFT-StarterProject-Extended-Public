//
//  InfiniteCarouselView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI
import Combine

// MARK: - Constants
fileprivate let scrollItems = [
	.onboardingCollect,
	.onboardingCompete,
	.onboardingExplore,
	.appIconSmall,
	.successPurchase,
	.big,
	.coverCollectionBig
].map { InfiniteCarouselItem(resource: $0) }

// MARK: - View
struct InfiniteCarouseTimelinelView: View {
	let topfirst: InfiniteCarouselPayload
	let topSecond: InfiniteCarouselPayload
	let topThird: InfiniteCarouselPayload
	let bottomFirst: InfiniteCarouselPayload
	let bottomSecond: InfiniteCarouselPayload
	let bottomThird: InfiniteCarouselPayload
	
	private let spacing: CGFloat = 16
	private let itemSize: CGFloat = Constants.onboardingCellSize
	private let rowItems = (0..<6).map { _ in scrollItems.shuffled() }
	private let topOffset: CGFloat = 16 * -6
	private let bottomOffset: CGFloat = 16 * 4
	
	var body: some View {
		let totalCycleWidth = (itemSize + spacing) * CGFloat(scrollItems.count)
		
		TimelineView(.animation) { timeline in
			VStack(spacing: spacing) {
				ForEach(0..<3, id: \.self) { index in
					makeRow(index: index, timeline: timeline, cycleWidth: totalCycleWidth)
				}
				.frame(height: itemSize)
				.clipped()
				.offset(y: topOffset)
				
				Spacer(minLength: spacing * 2)
				
				ForEach(3..<6, id: \.self) { index in
					makeRow(index: index, timeline: timeline, cycleWidth: totalCycleWidth)
				}
				.frame(height: itemSize)
				.clipped()
				.offset(y: bottomOffset)
			}
		}
		.ignoresSafeArea(edges: .bottom)
	}
}

// MARK: - InfiniteCarouseTimelinelView Extensions
// --- builder ---
private extension InfiniteCarouseTimelinelView {
	@ViewBuilder
	func makeRow(index: Int, timeline: TimelineViewDefaultContext, cycleWidth: CGFloat) -> some View {
		let payload = getPayloadFrom(index: index)
		let items = rowItems[index]
		let offset = calculateOffset(date: timeline.date, cycleWidth: cycleWidth, payload: payload)
		
		InfiniteCarouselContent(
			offsetX: offset,
			items: items,
			itemSize: itemSize,
			spacing: spacing
		)
	}
}

// --- calculations ---
private extension InfiniteCarouseTimelinelView {
	func getPayloadFrom(index: Int) -> InfiniteCarouselPayload {
		switch index {
		case 0:
			topfirst
		case 1:
			topSecond
		case 2:
			topThird
		case 3:
			bottomFirst
		case 4:
			bottomSecond
		case 5:
			bottomThird
		default:
			topfirst
		}
	}
	
	func calculateOffset(date: Date, cycleWidth: CGFloat, payload: InfiniteCarouselPayload) -> CGFloat {
		let time = date.timeIntervalSinceReferenceDate
		
		let shift = fmod(time * payload.speed * 90, Double(cycleWidth))
		return shift * (payload.direction == .leftToRight ? -1 : 1)
	}
}

// MARK: - Preview
#if DEBUG
#Preview("InifiniteScrollView") {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		InfiniteCarouseTimelinelView(
			topfirst: .init(direction: .leftToRight, speed: 0.9),
			topSecond: .init(direction: .rightToLeft, speed: 0.7),
			topThird: .init(direction: .leftToRight, speed: 0.8),
			bottomFirst: .init(direction: .rightToLeft, speed: 0.7),
			bottomSecond: .init(direction: .leftToRight, speed: 0.8),
			bottomThird: .init(direction: .rightToLeft, speed: 0.9)
		)
	}
}
#endif
