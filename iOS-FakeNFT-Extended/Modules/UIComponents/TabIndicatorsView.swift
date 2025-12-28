//
//  TabIndicatorsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct TabIndicatorsView<Items: RandomAccessCollection>: View where Items.Element: Hashable {
	let items: Items
	let selection: Items.Element
	var body: some View {
		HStack(spacing: 8) {
			ForEach(
				items,
				id: \.self
			) { item in
				RoundedRectangle(cornerRadius: Constants.tabIndicatorHeight / 2)
					.fill(selection == item ? .ypBlack : .ypBlack.opacity(0.2))
					.frame(height: Constants.tabIndicatorHeight)
			}
		}
		.animation(Constants.defaultAnimation, value: selection)
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
