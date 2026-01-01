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
						AsyncImageCached(urlString: imageURLString) { phase in
							switch phase {
							case .empty:
								ProgressView()
									.progressViewStyle(.circular)
							case .loaded(let image):
								Image(uiImage: image)
									.resizable()
									.scaledToFit()
							case .error:
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
		.aspectRatio(1, contentMode: .fit)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay(alignment: .topTrailing) {
			Button(action: likeAction) {
				favouriteImage
			}
		}
	}
	
	private var imageURLString: String {
		guard
			let model,
			!model.imagesURLsStrings.isEmpty,
			model.imagesURLsStrings.indices.contains(imageIndex)
		else { return "" }
		
		return model.imagesURLsStrings[imageIndex]
	}
	
	private func tryNextImage() {
		guard
			let model,
			!model.imagesURLsStrings.isEmpty
		else { return }
		
		imageIndex = (imageIndex + 1) % model.imagesURLsStrings.count
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
