//
//  NFTCartCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTCartCellView: View {
	
	let model: NFTModel
	let likeAction: () -> Void
	let cartAction: () -> Void
	
	private let layout: NFTCellLayout = .cart
	
	var body: some View {
		HStack(spacing: 20) {
			NFTImageView(
				model: model,
				layout: layout,
				likeAction: likeAction,
			)
			.frame(width: 108)
			
			VStack(spacing: 12) {
				NFTNameRateAuthorView(model: model, layout: layout)
				NFTCostView(model: model, layout: layout)
			}
			
			Spacer()
			
			cartButton
		}
		.padding(.horizontal, 16)
	}
	
	private var cartButton: some View {
		Button(action: cartAction) {
			(model.isFavorite ? Image.removeFromCart : Image.addToCart)
				.resizable()
				.foregroundStyle(.ypBlack)
				.font(.cartIcon)
				.frame(width: 40, height: 40)
		}
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
			LazyVStack(spacing: 24) {
				ForEach(models) {
					NFTCartCellView(
						model: $0,
						likeAction: {},
						cartAction: {}
					)
				}
			}
		}
	}
}
#endif
