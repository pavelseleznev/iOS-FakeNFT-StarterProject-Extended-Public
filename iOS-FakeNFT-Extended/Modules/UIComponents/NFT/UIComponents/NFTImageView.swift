//
//  NFTImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI
import Kingfisher

struct NFTImageView: View {
	
	let model: NFTModel
	let layout: NFTCellLayout
	let likeAction: () -> Void
	
	var body: some View {
		Group {
			if let url = URL(string: model.imageURLString) {
				KFImage(url)
					.resizable()
					.scaledToFit()
			} else {
				ZStack {
					Color.ypBackgroundUniversal
					Text("?")
						.font(.bold22)
						.foregroundStyle(.ypWhiteUniversal)
				}
			}
		}
		.overlay(alignment: .topTrailing) {
			Button(action: likeAction) {
				Image.heartFill
					.padding(.top, 10)
					.padding(.trailing, 8)
					.foregroundStyle(
						model.isFavorite ? .ypRedUniversal : .ypWhiteUniversal
					)
					.shadow(color: .ypBlackUniversal.opacity(0.6), radius: 10)
			}
		}
		.frame(
			width: layout.imageWidth,
			height: layout.imageHeight
		)
		.aspectRatio(1, contentMode: .fit)
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}
}
