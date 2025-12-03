//
//  NFTHorizontalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTHorizontalCell: View {
	var body: some View {
		HStack(spacing: 20) {
			Image(.nftCard)
				.resizable()
				.scaledToFit()
				.frame(maxHeight: 108)
				.overlay(alignment: .topTrailing) {
					Image.heartFill
						.padding(12)
						.shadow(color: .ypBlackUniversal.opacity(0.6), radius: 6)
				}
			
			VStack(alignment: .leading, spacing: 12) {
				VStack(alignment: .leading, spacing: 6) {
					Text("Toast")
						.foregroundStyle(.ypBlack)
						.font(.bold22)
					RatingPreview(rating: "2.5/5")
				}
				
				VStack(alignment: .leading, spacing: 6) {
					Text("Цена")
						.foregroundStyle(.ypBlack)
						.font(.regular13)
					
					Text("1,78 ETH")
						.foregroundStyle(.ypBlack)
						.font(.bold17)
				}
			}
			
			Spacer()
			
			Image.removeFromCart
				.resizable()
				.font(.cartIcon)
				.frame(width: 40, height: 40)
		}
	}
}
