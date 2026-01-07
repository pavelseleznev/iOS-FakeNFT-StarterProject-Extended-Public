//
//  InfiniteCarouselContent.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 07.01.2026.
//

import SwiftUI

struct InfiniteCarouselContent: View {
	let offsetX: CGFloat
	let items: [InfiniteCarouselItem]
	let itemSize: CGFloat
	let spacing: CGFloat
	
	private let repeats = 3
	
	var body: some View {
		HStack(spacing: 0) {
			ForEach(0..<repeats, id: \.self) { _ in
				HStack(spacing: 0) {
					ForEach(items, id: \.id) { item in
						LoopingScrollCellView(item: item)
							.opacity(0.6)
							.blur(radius: 1)
							.frame(width: itemSize)
							.padding(.trailing, spacing)
					}
				}
				.drawingGroup()
			}
		}
		.offset(x: offsetX)
		.drawingGroup()
	}
}
