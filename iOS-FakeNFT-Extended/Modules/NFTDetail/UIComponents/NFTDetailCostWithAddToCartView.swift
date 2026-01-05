//
//  NFTDetailCostWithAddToCartView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct NFTDetailCostWithAddToCartView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.model.isInCart == rhs.model.isInCart
	}
	
	let model: NFTModelContainer
	let cartAction: () -> Void
	let modelUpdateTriggerID: UUID
	
	var body: some View {
		HStack(spacing: 27) {
			NFTCostView(model: model.nft, layout: .cart)
			
			Button(action: cartAction) {
				Text(model.isInCart ? .removeFromCartText : .addToCartText)
					.font(.bold17)
					.foregroundStyle(.ypWhite)
					.contentTransition(.numericText())
			}
			.nftButtonStyle(filled: true)
			.offset(y: -10)
			.animation(Constants.defaultAnimation, value: model.isInCart)
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
