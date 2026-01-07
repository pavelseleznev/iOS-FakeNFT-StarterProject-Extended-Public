//
//  NFTDetailToolbarView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct NFTDetailToolbarView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.model.id == rhs.model.id &&
		lhs.isImageFullScreen == rhs.isImageFullScreen &&
		lhs.isImageDissapeared == rhs.isImageDissapeared
	}
	
	let model: NFTModelContainer
	@Binding var isImageFullScreen: Bool
	let isImageDissapeared: Bool
	let backAction: () -> Void
	let didTapLikeButton: () -> Void
	let modelUpdateTriggerID: UUID
	
	var body: some View {
		HStack {
			Group {
				if isImageFullScreen {
					HStack {
						Spacer()
						Button {
							withAnimation(.easeInOut(duration: 0.25)) {
								isImageFullScreen = false
							}
						} label: {
							Image.xmark
								.resizable()
								.font(.xmarkIcon)
								.foregroundStyle(.ypBlack)
								.frame(width: 18, height: 18)
								.buttonDefaultFrame()
						}
					}
				} else {
					Button(action: backAction) {
						Image.chevronLeft
							.resizable()
							.font(.chevronLeftIcon)
							.foregroundStyle(.cyan)
							.blendMode(.difference)
							.frame(width: 12, height: 20)
							.buttonDefaultFrame()
					}
					
					Spacer()
					Button {
						HapticPerfromer.shared.play(.impact(.light))
						didTapLikeButton()
					} label: {
						Image.heartFill
							.resizable()
							.foregroundStyle(model.isFavorite ? .ypRedUniversal : .secondary)
							.shadow(
								color: isImageDissapeared ? .clear : .ypBlackUniversal,
								radius: 10
							)
							.frame(width: 21, height: 18)
							.buttonDefaultFrame()
							.animation(Constants.defaultAnimation, value: model.isFavorite)
					}
				}
			}
			.offset(y: 8)
		}
		.padding(.horizontal, 8)
		.padding(.trailing, 4)
		.padding(.bottom)
		.background(backgroundView)
	}
	
	@ViewBuilder
	private var backgroundView: some View {
		if isImageDissapeared {
			RoundedRectangle(cornerRadius: 0)
				.fill(.ultraThinMaterial)
				.shadow(color: .ypBlackUniversal.opacity(0.3), radius: 10)
				.ignoresSafeArea(edges: .top)
				.transition(.opacity.animation(Constants.defaultAnimation))
		}
	}
}

// MARK: - View helper
private extension View {
	func buttonDefaultFrame() -> some View {
		self
			.frame(width: 24, height: 24)
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	GeometryReader { geo in
		ZStack(alignment: .top) {
			Color.cyan.ignoresSafeArea()
			
			NFTDetailToolbarView(
				model: .mock,
				isImageFullScreen: .constant(false),
				isImageDissapeared: false,
				backAction: {},
				didTapLikeButton: {},
				modelUpdateTriggerID: .init()
			)
			.offset(y: geo.safeAreaInsets.top)
		}
		.frame(
			width: geo.size.width,
			height: geo.size.height + geo.safeAreaInsets.top
		)
		.ignoresSafeArea()
	}
}
#endif
