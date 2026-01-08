//
//  NFTCompactCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTCompactCellView: View {
	let model: NFTResponse?
	let isFavourited: Bool?
	let likeAction: () -> Void
	
	private let layout: NFTCellLayout = .compact
	
	var body: some View {
		HStack(spacing: 12) {
			NFTImageView(
				model: model,
				isFavourited: isFavourited,
				layout: layout,
				likeAction: likeAction,
			)
			
			VStack(alignment: .leading, spacing: 8) {
				NFTNameRateAuthorView(
					model: model,
					layout: layout
				)
				NFTCostView(model: model, layout: layout)
			}
			Spacer()
		}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var models: [NFTResponse] = [
		.mock,
		.mock,
		.badImageURLMock,
		.mock,
		.badImageURLMock
	]
	
	@Previewable let columns = [
		GridItem(.flexible(), spacing: 8),
		GridItem(.flexible())
	]
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		ScrollView(.vertical) {
			LazyVGrid(
				columns: columns,
				alignment: .center,
				spacing: 20
			) {
				ForEach(models) {
					NFTCompactCellView(
						model: $0,
						isFavourited: false,
						likeAction: {}
					)
				}
			}
			.safeAreaPadding(.leading)
			.safeAreaPadding(.top)
		}
	}
}
#endif
