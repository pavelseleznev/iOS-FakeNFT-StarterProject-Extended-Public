//
//  NFTDetailImagesView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

fileprivate let maxScale: CGFloat = 3
fileprivate let minScale: CGFloat = 0.5
fileprivate let dismissScaleRatio: CGFloat = 0.1

struct NFTDetailImagesView: View {
	let nftsImagesURLsStrings: [String]
	let screenWidth: CGFloat
	let isFavourite: Bool
	@Binding var isFullScreen: Bool
	
	@State private var isDismissing = false
	@State private var scale: CGFloat = 1
	@State private var baseScale: CGFloat?
	@State private var selection: String?
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			TabView(selection: $selection) {
				Group {
					if nftsImagesURLsStrings.isEmpty {
						LoadingShimmerPlaceholderView()
							.transition(.scale.combined(with: .opacity))
					} else {
						content
							.transition(.scale.combined(with: .opacity))
					}
				}
			}
			.gesture(dismissGesture)
			.scaleEffect(y: isDismissing ? scale : 1)
			.tabViewStyle(.page(indexDisplayMode: .never))
			.background(
				LinearGradient(
					colors: [.purple, .indigo, .cyan],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.blur(radius: 50, opaque: true)
				.opacity(isFullScreen ? 0 : 0.6)
			)
			.clipShape(
				RoundedRectangle(
					cornerRadius: isFullScreen ? 0 : 40,
					style: .continuous
				)
			)
			.stretchy()
			.overlay(alignment: .bottom) {
				tabSelectorsView
			}
		}
		.animation(Constants.defaultAnimation, value: isDismissing)
		.onChange(of: isFullScreen) { resetScale() }
		.onAppear(perform: setFirstSelection)
	}
}

// MARK: - NFTDetailImagesView Extensions

// --- private subviews ---
private extension NFTDetailImagesView {
	var tabSelectorsView: some View {
		TabIndicatorsView(
			items: nftsImagesURLsStrings,
			selection: selection
		)
		.offset(y: 16)
		.padding(.horizontal, 16)
	}
	
	var content: some View {
		ForEach(nftsImagesURLsStrings, id: \.self) { imageURLString in
			AsyncImage(
				url: URL(string: imageURLString),
				transaction: .init(animation: Constants.defaultAnimation)
			) { phase in
				switch phase {
				case .empty:
					LoadingView(loadingState: .fetching)
				case .success(let image):
					loadedImageView(image, isSelected: selection == imageURLString)
				default:
					ZStack {
						Text(.loadingError)
							.font(.bold22)
							.foregroundStyle(.ypBlack)
					}
				}
			}
			.tag(imageURLString)
			.id(imageURLString)
		}
	}
	
	func loadedImageView(_ image: Image, isSelected: Bool) -> some View {
		ZStack {
			Color.ypWhite
			
			image
				.resizable()
				.aspectRatio(1, contentMode: .fit)
				.scaleEffect(isSelected ? scale : 1)
				.onTapGesture(count: 2) {
					withAnimation(Constants.defaultAnimation) {
						scale = 1
					}
				}
				.onAppear {
					withAnimation(Constants.defaultAnimation) {
						scale = 1
					}
				}
		}
		.gesture(magnificationGesture)
	}
}

// --- private methods ---
private extension NFTDetailImagesView {
	func resetScale(checkForClippingBounds: Bool = false) {
		isDismissing = false
		
		withAnimation(Constants.defaultAnimation) {
			scale = checkForClippingBounds ? min(maxScale, max(minScale, scale)) : 1
			baseScale = nil
		}
	}
	
	func setFirstSelection() {
		selection = nftsImagesURLsStrings.first
	}
}

// --- private gestures ---
private extension NFTDetailImagesView {
	var magnificationGesture: some Gesture {
		MagnificationGesture()
			.onChanged { value in
				guard isFullScreen else { return }
				
				if baseScale == nil {
					baseScale = scale
				}
				
				isDismissing = false
				scale = (baseScale ?? 1) * value
			}
			.onEnded { _ in
				guard isFullScreen else { return }
				
				isDismissing = false
				resetScale(checkForClippingBounds: true)
			}
	}
	
	var dismissGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				let isBottomToTopDrag = value.translation.height < 0
				guard isFullScreen && isBottomToTopDrag else { return }
				
				if !isDismissing {
					resetScale()
				}
				
				let newScale = abs(value.translation.height / screenWidth * dismissScaleRatio) + 1
				
				if baseScale == nil {
					baseScale = scale
				}
				
				isDismissing = true
				scale = (baseScale ?? 1) * newScale
				
				if scale > 1.1 {
					withAnimation(Constants.defaultAnimation) {
						isFullScreen = false
					}
				}
			}
			.onEnded { _ in
				guard isFullScreen else { return }
				resetScale()
			}
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	GeometryReader { geo in
		NavigationStack {
			NFTDetailImagesView(
				nftsImagesURLsStrings: [
					"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/1.png",
					"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/2.png",
					"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/3.png"
				],
				screenWidth: geo.size.width,
				isFavourite: false,
				isFullScreen: .constant(true)
			)
		}
	}
}
#endif
