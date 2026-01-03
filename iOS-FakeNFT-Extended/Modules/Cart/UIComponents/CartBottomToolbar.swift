//
//  CartBottomToolbar.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct CartBottomToolbar: View {
	private let cartActionBottomToolbarHeight: CGFloat = 76
	
	let nftCount: Int
	let costLabel: String
	let performPayment: () -> Void
	let isLoaded: Bool
	
	var body: some View {
		HStack(spacing: 24) {
			VStack(alignment: .leading, spacing: 6) {
				Text(.nft(nftCount))
					.font(.regular15)
					.foregroundStyle(.ypBlack)
				Text(costLabel)
					.font(.bold17)
					.foregroundStyle(.ypGreenUniversal)
					.contentTransition(.numericText(countsDown: false))
					.animation(
						.easeInOut(duration: 0.075),
						value: costLabel
					)
			}
			.frame(width: 100, alignment: .leading)
			
			Button(action: performPayment) {
				RoundedRectangle(cornerRadius: 16)
					.fill(isLoaded ? .ypBlack : .ypBackgroundUniversal)
					.overlay {
						if isLoaded {
							Text(.toPayment)
								.font(.bold17)
								.foregroundStyle(.ypWhite)
						} else {
							ProgressView()
								.colorMultiply(.ypWhite)
								.progressViewStyle(.circular)
						}
					}
					.padding(.vertical)
			}
			.disabled(!isLoaded)
		}
		.frame(height: cartActionBottomToolbarHeight)
		.padding(.horizontal)
		.background(cartActionBackground)
		.opacity(nftCount > 0 ? 1 : 0)
	}
	
	private var cartActionBackground: some View {
		UnevenRoundedRectangle(
			cornerRadii: .init(
				topLeading: 12,
				topTrailing: 12
			),
			style: .continuous
		)
		.fill(.ypLightGrey)
		.shadow(
			color: .ypBlackUniversal.opacity(0.2),
			radius: 10
		)
	}
}
