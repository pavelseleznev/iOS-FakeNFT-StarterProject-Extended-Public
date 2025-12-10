//
//  NFTVerticalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTVerticalCell: View {
	
	let model: NFTModel
	let likeAction: () -> Void
	let cartAction: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			NFTImageView(
				model: model,
				layout: .my,
				likeAction: likeAction,
			)
			
			RatingPreview(rating: model.rate)
			
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(model.name)
						.foregroundStyle(.ypBlack)
						.font(.bold17)
						.lineLimit(5)
						.truncationMode(.tail)
					
					Text(model.cost)
						.foregroundStyle(.ypBlack)
						.font(.medium10)
				}
				Spacer()
				Button(action: cartAction) {
					Image.addToCart
						.resizable()
						.font(.cartIcon)
						.foregroundStyle(.ypBlack)
						.frame(width: 40, height: 40)
				}
			}
		}
	}
}
