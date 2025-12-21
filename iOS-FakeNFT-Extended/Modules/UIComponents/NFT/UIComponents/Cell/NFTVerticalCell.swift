//
//  NFTVerticalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTVerticalCell: View {
	
	let model: NFTModelContainer
	let likeAction: () -> Void
	let cartAction: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			NFTImageView(
				model: model.nft,
				isFavourited: model.isFavorite,
				layout: .my,
				likeAction: likeAction,
			)
			
			RatingPreview(rating: model.nft.rating)
			
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(model.nft.name)
						.foregroundStyle(.ypBlack)
						.font(.bold17)
						.lineLimit(2)
						.truncationMode(.tail)
					
					Text(
						String(format: "%.2f", model.nft.price)
							.replacingOccurrences(of: ".", with: ",")
						+ " ETH"
					)
					.foregroundStyle(.ypBlack)
					.font(.medium10)
				}
				Spacer()
				Button(action: cartAction) {
					(model.isInCart ? Image.removeFromCart : Image.addToCart)
						.resizable()
						.font(.cartIcon)
						.foregroundStyle(.ypBlack)
						.frame(width: 40, height: 40)
				}
			}
		}
	}
}
