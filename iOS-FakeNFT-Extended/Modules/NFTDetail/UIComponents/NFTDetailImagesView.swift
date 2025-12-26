//
//  NFTDetailImagesView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

struct NFTDetailImagesView: View {
	let nftsImagesURLsStrings: [String]
	let isFavourite: Bool
	let isFullScreen: Bool
	
	@State private var scale: CGFloat = 1
	@State private var baseScale: CGFloat?
	@State private var selection: String?
	private let maxScale: CGFloat = 3
	private let minScale: CGFloat = 0.5
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			TabView(selection: $selection) {
				if nftsImagesURLsStrings.isEmpty {
					LoadingShimmerPlaceholderView()
				} else {
					ForEach(nftsImagesURLsStrings, id: \.self) { imageURLString in
						AsyncImage(
							url: URL(string: imageURLString),
							transaction: .init(animation: .easeInOut(duration: 0.15))
						) { phase in
							switch phase {
							case .empty:
								LoadingView(loadingState: .fetching)
							case .success(let image):
								ZStack {
									Color.ypWhite
									
									image
										.resizable()
										.aspectRatio(1, contentMode: .fit)
										.scaleEffect(selection == imageURLString ? scale : 1)
										.onTapGesture(count: 2) {
											withAnimation(.easeInOut(duration: 0.15)) {
												scale = 1
											}
										}
										.onAppear {
											withAnimation(.easeInOut(duration: 0.15)) {
												scale = 1
											}
										}
								}
								.gesture(gesture)
							default:
								Text("Ошибка загрузки")
									.font(.bold22)
									.foregroundStyle(.ypBlack)
							}
						}
						.tag(imageURLString)
						.id(imageURLString)
					}
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.clipShape(
				RoundedRectangle(
					cornerRadius: isFullScreen ? 0 : 40,
					style: .continuous
				)
			)
			.stretchy(isImageFullScreen: isFullScreen)
			.overlay(alignment: .bottom) {
				tabSelectorsView
			}
		}
		.onAppear {
			selection = nftsImagesURLsStrings.first
		}
	}
	
	private var tabSelectorsView: some View {
		HStack {
			ForEach(
				nftsImagesURLsStrings,
				id: \.self
			) { imageURLString in
				RoundedRectangle(cornerRadius: 12)
					.fill(selection == imageURLString ? .ypBlack : .ypGrayUniversal)
					.frame(height: 4)
			}
		}
		.offset(y: 16)
		.padding(.horizontal, 16)
	}
	
	private var gesture: some Gesture {
		MagnificationGesture()
			.onChanged { value in
				if baseScale == nil {
					baseScale = scale
				}
				
				scale = (baseScale ?? 1) * value
			}
			.onEnded { _ in
				withAnimation(.easeInOut(duration: 0.15)) {
					scale = min(maxScale, max(minScale, scale))
					baseScale = nil
				}
			}
//			DragGesture()
//				.onChanged { value in
//					if scales[imageURLString, default: 1] > 1 {  // ← КЛЮЧ!
//						let lastOffset = offsets[imageURLString, default: .zero]
//						offsets[imageURLString, default: .zero] = CGSize(
//							width: value.location.x + lastOffset.width,
//							height: value.location.y + lastOffset.height
//						)
//					}
//					// Если scale == 1, gesture NE срабатывает
//					// → TabView свайп работает нормально!
//				}
//				.onEnded { value in
//					if scales[imageURLString, default: .zero] > 1 {
//						print(value.translation.width)
////													  lastOffset = offset
//						withAnimation(.spring()) {
//							// коррекция границ
//						}
//					}
//					if value.location.x < 0 || value.location.y < 0 {
//						withAnimation(
//							.easeInOut(duration: 0.15)
//						) {
//							offsets[imageURLString, default: .zero] = .zero
//						}
//					}
//				}
//		)
	}
}

#if DEBUG
#Preview {
	NavigationStack {
		NFTDetailImagesView(
			nftsImagesURLsStrings: [
				"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/1.png",
				"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/2.png",
				"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/3.png"
			],
			isFavourite: false,
			isFullScreen: true
		)
	}
}
#endif
