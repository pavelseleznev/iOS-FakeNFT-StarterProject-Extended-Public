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
		Color.ypBackgroundUniversal
			.overlay {
				if imageURLString.isEmpty {
					Text("?")
						.font(.bold22)
						.foregroundStyle(.ypWhiteUniversal)
						.transition(.opacity.animation(Constants.defaultAnimation))
				} else {
					AsyncImageCached(urlString: imageURLString) { phase in
						switch phase {
						case .empty:
							ProgressView()
								.progressViewStyle(.circular)
						case .error:
							ProgressView()
								.progressViewStyle(.circular)
						case .loaded(let image):
							Image(uiImage: image)
								.resizable()
								.transition(.opacity.animation(Constants.defaultAnimation))
						}
					}
					.transition(.opacity.animation(Constants.defaultAnimation))
				}
			}
			.aspectRatio(1, contentMode: .fit)
			.overlay(alignment: .topTrailing, content: favouriteImageButton)
			.applySkeleton(model)
			.clipShape(.buttonBorder)
	}
}

// MARK: - NFTImageView Extensions
// --- subviews ---
private extension NFTImageView {
	func favouriteImageButton() -> some View {
		Button {
			HapticPerfromer.shared.play(.impact(.medium))
			likeAction()
		} label: {
			favouriteImage
		}
	}
	
	var favouriteImage: some View {
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

// -- helpers ---
private extension NFTImageView {
	var imageURLString: String {
	   model?.imagesURLsStrings.first ?? ""
   }
}

extension NFTImageView: @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.model?.id == rhs.model?.id &&
		lhs.isFavourited == rhs.isFavourited
	}
}
