//
//  NFTDetailScrollViewHandlerView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

//fileprivate let threshold: CGFloat = 100

struct NFTDetailScrollViewHandlerView: View {
	let scrollCoordinateSpace: String
	
	var body: some View {
		GeometryReader {
			Color.clear
				.preference(
					key: ScrollOffsetPreferenceKey.self,
					value: $0.frame(in: .named(scrollCoordinateSpace)).minY
				)
		}
		.frame(height: 0)
	}
}

struct ScrollOffsetPreferenceKey: @MainActor PreferenceKey {
	@MainActor static var defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}

#if DEBUG
#Preview {
	ScrollView(.vertical) {
		NFTDetailScrollViewHandlerView(
			scrollCoordinateSpace: "scroll"
		)
	}
	.coordinateSpace(.named("scroll"))
	.onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
		print(offset)
	}
}
#endif
