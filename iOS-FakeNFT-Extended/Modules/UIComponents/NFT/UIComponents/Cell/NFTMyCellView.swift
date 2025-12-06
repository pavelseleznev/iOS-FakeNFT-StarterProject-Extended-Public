//
//  NFTHorizontalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTMyCellView: View {
	
	let model: NFTModel
	let likeAction: () -> Void
	
	private let layout: NFTCellLayout = .my
	
	var body: some View {
		HStack(spacing: 20) {
			NFTImageView(
				model: model,
				layout: layout,
				likeAction: likeAction,
			)
			
			HStack {
				NFTNameRateAuthorView(model: model, layout: layout)
				Spacer()
				NFTCostView(model: model, layout: layout)
			}
			.padding(.trailing, 30)
		}
		.padding(.horizontal, 16)
	}
}

#if DEBUG
#Preview {
	@Previewable @State var models: [NFTModel] = [
		.mock,
		.mock,
		.badImageURLMock,
		.mock,
		.badImageURLMock
	]
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		ScrollView(.vertical) {
			LazyVStack(alignment: .leading, spacing: 32) {
				ForEach(models) {
					NFTMyCellView(model: $0, likeAction: {})
				}
			}
		}
	}
}
#endif

