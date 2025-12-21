//
//  NFTCartCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTCartCellView: View {
	
	let model: NFTResponse
	let isFavourited: Bool
	let likeAction: () -> Void
	let cartAction: () -> Void
	
	private let layout: NFTCellLayout = .cart
	
	var body: some View {
		HStack(spacing: 20) {
			NFTImageView(
				model: model,
				isFavorited: isFavourited,
				layout: layout,
				likeAction: likeAction,
			)
			.frame(width: 108)
			
			VStack(spacing: 12) {
				NFTNameRateAuthorView(
					model: model,
					layout: layout
				)
				NFTCostView(model: model, layout: layout)
			}
			
			Spacer()
			
			cartButton
		}
		.padding(.horizontal, 16)
	}
	
	private var cartButton: some View {
		Button(action: cartAction) {
			(isFavourited ? Image.removeFromCart : Image.addToCart)
				.resizable()
				.foregroundStyle(.ypBlack)
				.font(.cartIcon)
				.frame(width: 40, height: 40)
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
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		ScrollView(.vertical) {
			LazyVStack(spacing: 24) {
				ForEach(models) {
					NFTCartCellView(
						model: $0,
						isFavourited: false,
						likeAction: {},
						cartAction: {}
					)
				}
			}
		}
	}
}
#endif
