//
//  NFTImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTImageView: View {
	
	let model: NFTResponse?
	let isFavourited: Bool?
	let layout: NFTCellLayout
	let likeAction: () -> Void
	
	var body: some View {
		Group {
			if model != nil {
				AsyncImage(url: imageURL) { image in
					image
						.resizable()
				} placeholder: {
					Color.ypBackgroundUniversal
						.overlay {
							ProgressView()
								.progressViewStyle(.circular)
						}
				}
			} else {
				LoadingShimmerPlaceholderView()
			}
		}
		.scaledToFit()
		.overlay(alignment: .topTrailing) {
			Button(action: likeAction) {
				favouriteImage
			}
		}
		.aspectRatio(1, contentMode: .fit)
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}
	
	private var imageURL: URL? {
		URL(string: model?.imagesURLsStrings.first ?? "")
	}
	
	private var favouriteImage: some View {
		Group {
			if let isFavourited {
				Image.heartFill
					.foregroundStyle(
						isFavourited ? .ypRedUniversal : .ypWhiteUniversal
					)
			} else {
				LoadingShimmerPlaceholderView()
					.frame(width: 24, height: 24)
			}
		}
		.padding(.top, 10)
		.padding(.trailing, 8)
		.shadow(color: .ypBlackUniversal.opacity(0.6), radius: 10)
	}
}
