//
//  CartNFTRemovalApproveAlertView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct CartNFTRemovalApproveAlertView: View {
	private let contentWidth: CGFloat = 180
	
	let model: NFTModelContainer?
	let removeAction: () -> Void
	let dismissAction: () -> Void
	
	var body: some View {
		VStack(spacing: 20) {
			VStack(spacing: 12) {
				NFTCartImageView(model: model?.nft, layout: .cart)
					.padding(.horizontal)
					.padding(.horizontal)
				
				Text(.sureToRemoveObjectFromCart)
					.font(.regular13)
					.foregroundStyle(.ypBlack)
					.multilineTextAlignment(.center)
			}
			.frame(width: contentWidth)
			
			HStack {
				Button(role: .destructive, action: removeAction) {
					Text(.delete)
						.frame(width: 84)
						.padding(.horizontal)
						.padding(.vertical, 12)
						.background(
							RoundedRectangle(cornerRadius: 12)
								.fill(.ypBlack)
						)
				}
				Button(role: .cancel, action: dismissAction) {
					Text(.back)
						.frame(width: 84)
						.padding(.horizontal)
						.padding(.vertical, 12)
						.foregroundStyle(.ypWhite)
						.background(
							RoundedRectangle(cornerRadius: 12)
								.fill(.ypBlack)
						)
				}
			}
		}
	}
}

#if DEBUG
#Preview {
	CartNFTRemovalApproveAlertView(
		model: .mock,
		removeAction: {},
		dismissAction: {}
	)
}
#endif
