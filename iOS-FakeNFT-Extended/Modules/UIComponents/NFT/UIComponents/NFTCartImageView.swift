//
//  NFTCartImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct NFTCartImageView: View {
	
	let model: NFTResponse?
	let layout: NFTCellLayout
	
	@State private var imageIndex: Int = 0
	
	var body: some View {
		Group {
			if model != nil {
				Color.ypBackgroundUniversal
					.overlay {
						AsyncImage(
							url: imageURL,
							transaction: .init(animation: .easeInOut(duration: 0.15))
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
			imageIndex = 0
			urlString = ""
		}
		
		return URL(string: urlString)
	}
	
	private func tryNextImage() {
		imageIndex += 1
	}
}
