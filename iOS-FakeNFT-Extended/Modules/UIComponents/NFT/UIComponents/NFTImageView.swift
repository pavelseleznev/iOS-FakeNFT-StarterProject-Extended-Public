//
//  NFTImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTImageView: View {
	
	let model: NFTResponse
	let isFavourited: Bool
	let layout: NFTCellLayout
	let likeAction: () -> Void
	
	var body: some View {
		Group {
			if
				let imageURLString = model.imagesURLsStrings.first,
				let url = URL(string: imageURLString)
			{
				AsyncImage(url: url) { image in
					image
						.resizable()
				} placeholder: {
					ZStack {
						Color.ypBackgroundUniversal
						ProgressView()
							.progressViewStyle(.circular)
					}
				}
			} else {
				ZStack {
					Color.ypBackgroundUniversal
					Text("?")
						.font(.bold22)
						.foregroundStyle(.ypWhiteUniversal)
				}
			}
		}
		.scaledToFit()
		.overlay(alignment: .topTrailing) {
			Button(action: likeAction) {
				Image.heartFill
					.padding(.top, 10)
					.padding(.trailing, 8)
					.foregroundStyle(
						isFavourited ? .ypRedUniversal : .ypWhiteUniversal
					)
					.shadow(color: .ypBlackUniversal.opacity(0.6), radius: 10)
			}
		}
		.aspectRatio(1, contentMode: .fit)
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}
}
