//
//  NFTVerticalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTVerticalCell: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Image(.nftCard)
				.resizable()
				.scaledToFit()
				.overlay(alignment: .topTrailing) {
					Image.heartFill
						.padding(12)
						.shadow(color: .ypBlackUniversal.opacity(0.6), radius: 6)
				}
			
			RatingPreview(rating: "2.5/5")
			
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text("Toast")
						.foregroundStyle(.ypBlack)
						.font(.bold22)
					
					Text("1,78 ETH")
						.foregroundStyle(.ypBlack)
						.font(.medium10)
				}
				Spacer()
				Image.addToCart
					.resizable()
					.font(.cartIcon)
					.frame(width: 40, height: 40)
			}
		}
	}
}
