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
						}
					}
				}
				.applySkeleton(model)
		}
		.scaledToFit()
		.aspectRatio(1, contentMode: .fit)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay(alignment: .topTrailing, content: favouriteImageButton)
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
		lhs.model?.id == rhs.model?.id
	}
}
