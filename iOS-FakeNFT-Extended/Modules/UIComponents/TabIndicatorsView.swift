//
//  TabIndicatorsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct TabIndicatorsView<Items: RandomAccessCollection>: View where Items.Element: Hashable {
	private let items: Items
	private let selection: Items.Element
	private let autoscrollProgress: CGFloat
	private let isConstantAppearance: Bool
	
	init(
		items: Items,
		selection: Items.Element,
		autoscrollProgress: CGFloat = 0,
		isConstantAppearance: Bool = false
	) {
		self.items = items
		self.selection = selection
		self.autoscrollProgress = autoscrollProgress
		self.isConstantAppearance = isConstantAppearance
	}
	
	var body: some View {
		HStack(spacing: 8) {
			ForEach(
				items,
				id: \.self
			) { item in
				Capsule()
					.fill(isConstantAppearance ? .ypWhiteUniversal : .ypBlack)
					.opacity(selection == item ? 1 : 0.2)
					.frame(height: Constants.tabIndicatorHeight)
					.overlay { progressView(item) }
			}
		}
		.animation(Constants.defaultAnimation, value: selection)
	}
	
	@ViewBuilder
	private func progressView(_ item: Items.Element) -> some View {
		if selection == item {
			Color.ypGrayUniversal
				.opacity(0.4)
				.scaleEffect(x: autoscrollProgress, anchor: .leading)
		}
	}
}

#if DEBUG
#Preview {
	@Previewable let imagesURLStrings: [String] = [
		"a",
		"b",
		"c"
	]
	@Previewable let selection: String = "a"
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		TabIndicatorsView(
			items: imagesURLStrings,
			selection: selection
		)
	}
}
#endif
