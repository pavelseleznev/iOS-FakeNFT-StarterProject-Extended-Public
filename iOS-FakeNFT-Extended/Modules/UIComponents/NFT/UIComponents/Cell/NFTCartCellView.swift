//
//  NFTCartCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTCartCellView: View {
	let model: NFTModelContainer?
	let cartAction: () -> Void
	
	private let layout: NFTCellLayout = .cart
	
	var body: some View {
		HStack(spacing: 20) {
			NFTCartImageView(
				model: model?.nft,
				layout: layout
			)
			.frame(width: 108)
			
			VStack(alignment: .leading, spacing: 12) {
				NFTNameRateAuthorView(
					model: model?.nft,
					layout: layout
				)
				NFTCostView(model: model?.nft, layout: layout)
			}
			
			Spacer()
			
			cartButton
		}
		.padding(.horizontal, 16)
	}
	
	private var cartButton: some View {
		Button(action: cartAction) {
			((model?.isInCart ?? false) ? Image.removeFromCart : Image.addToCart)
				.resizable()
				.foregroundStyle(.ypBlack)
				.font(.cartIcon)
				.frame(width: 40, height: 40)
				.applySkeleton(model)
		}
		.buttonStyle(.plain)
		.disabled(model == nil)
	}
}

#if DEBUG
#Preview {
	@Previewable @State var models: [NFTModelContainer] = [
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
						cartAction: {}
					)
				}
			}
		}
	}
}
#endif
