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
	
	var body: some View {
		Color.ypBackgroundUniversal
			.overlay {
				if imageURLString.isEmpty {
					Text("?")
						.font(.bold22)
						.foregroundStyle(.ypWhiteUniversal)
						.transition(.opacity)
				} else {
					AsyncImageCached(urlString: imageURLString) { phase in
						switch phase {
						case .empty:
							ProgressView()
						case .error:
							ProgressView()
						case .loaded(let image):
							Image(uiImage: image)
								.resizable()
								.transition(.opacity.animation(Constants.defaultAnimation))
						}
					}
					.progressViewStyle(.circular)
					.transition(.opacity)
				}
			}
			.aspectRatio(1, contentMode: .fit)
			.applySkeleton(model)
			.clipShape(.buttonBorder)
	}
	
	private var imageURLString: String {
		model?.imagesURLsStrings.first ?? ""
	}
}
