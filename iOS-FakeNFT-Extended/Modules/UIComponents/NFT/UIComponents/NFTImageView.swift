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
	
	@State private var imageIndex: Int = 0
	
	var body: some View {
		Group {
			if model != nil {
				Color.ypBackgroundUniversal
					.overlay {
						AsyncImage(
							url: imageURL,
							transaction: .init(animation: Constants.defaultAnimation)
						) { phase in
							switch phase {
							case .empty:
								ProgressView()
									.progressViewStyle(.circular)
							case .success(let image):
								image
									.resizable()
									.scaledToFit()
							default:
								Text("?")
									.font(.bold22)
									.foregroundStyle(.ypWhiteUniversal)
									.onAppear(perform: tryNextImage)
							}
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
		let urlString: String
		if
			let model,
			model.imagesURLsStrings.indices.contains(imageIndex)
		{
			urlString = model.imagesURLsStrings[imageIndex]
		} else {
			urlString = ""
		}
		
		return URL(string: urlString)
	}
	
	private func tryNextImage() {
		imageIndex += 1
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
		.shadow(
			color: .ypBlackUniversal,
			radius: 8
		)
	}
}
