//
//  NFTDetailCostWithAddToCartView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct NFTDetailCostWithAddToCartView: View {
	let model: NFTModelContainer
	let cartAction: () -> Void
	let modelUpdateTriggerID: UUID
	
	var body: some View {
		HStack(spacing: 27) {
			NFTCostView(model: model.nft, layout: .cart)
			
			Button(action: cartAction) {
				Text(
					model.isInCart ? .removeFromCartText : .addToCartText)
					.font(.bold17)
					.foregroundStyle(.ypWhite)
			}
			.nftButtonStyle(filled: true)
			.offset(y: -10)
			.id(modelUpdateTriggerID)
		}
		.padding(.horizontal)
	}
}

#if DEBUG
#Preview {
	NFTDetailCostWithAddToCartView(
		model: .mock,
		cartAction: {},
		modelUpdateTriggerID: .init()
	)
}
#endif
