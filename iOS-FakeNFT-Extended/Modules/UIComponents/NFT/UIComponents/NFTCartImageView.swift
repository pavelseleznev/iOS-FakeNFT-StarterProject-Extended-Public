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
		AsyncImageCached(urlString: imageURLString) { phase in
			switch phase {
			case .empty:
				Color.ypBackgroundUniversal
					.overlay {
						ProgressView()
							.progressViewStyle(.circular)
					}
			case .loaded(let image):
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
			case .error:
				Color.ypBackgroundUniversal
					.overlay {
						Text("?")
							.font(.bold22)
							.foregroundStyle(.ypWhiteUniversal)
							.onAppear(perform: tryNextImage)
					}
			}
		}
		.applySkeleton(model)
		.scaledToFit()
		.aspectRatio(1, contentMode: .fit)
		.clipShape(RoundedRectangle(cornerRadius: 12))
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
}
