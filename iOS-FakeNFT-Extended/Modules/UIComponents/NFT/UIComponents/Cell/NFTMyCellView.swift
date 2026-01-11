//
//  NFTHorizontalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTMyCellView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.model?.id == rhs.model?.id &&
		lhs.isFavourited == rhs.isFavourited
	}
	
	let model: NFTResponse?
	let isFavourited: Bool?
	let likeAction: () -> Void
	
	private let layout: NFTCellLayout = .my
	
	var body: some View {
		HStack(spacing: 20) {
			NFTImageView(
				model: model,
				isFavourited: isFavourited,
				layout: layout,
				likeAction: likeAction,
			)
			.frame(width: 108)
			
			NFTNameRateAuthorView(
				model: model,
				layout: layout
			)
			.scaleEffect(model == nil ? 1 : 1.1)
			
			Spacer()
			
			NFTCostView(model: model, layout: layout)
				.scaleEffect(1.2)
				.frame(maxWidth: 90, alignment: .leading)
			
		}
		.padding(.horizontal, 16)
		.frame(height: 108)
		.fixedSize(horizontal: false, vertical: true)
	}
}

#if DEBUG
#Preview {
	@Previewable @State var models: [NFTResponse?] = [
		.mock,
		nil,
		.badImageURLMock,
		.mock,
		.badImageURLMock
	]
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		ScrollView(.vertical) {
			LazyVStack(alignment: .leading, spacing: 32) {
				ForEach(Array(models.enumerated()), id: \.offset) {
					NFTMyCellView(
						model: $0.element,
						isFavourited: false,
						likeAction: {}
					)
				}
			}
		}
	}
}
#endif
