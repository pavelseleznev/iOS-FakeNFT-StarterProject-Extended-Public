//
//  NFTDetailToolbarView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct NFTDetailToolbarView: View {
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
							.foregroundStyle(.ypBlack)
							.frame(width: 9, height: 16)
							.buttonDefaultFrame()
					}
					Spacer()
					Button(action: didTapLikeButton) {
						Image.heartFill
							.resizable()
							.foregroundStyle(model.isFavorite ? .ypRedUniversal : .secondary)
							.frame(width: 21, height: 18)
							.buttonDefaultFrame()
							.id(modelUpdateTriggerID)
					}
				}
			}
			.shadow(
				color: isImageDissapeared ? .clear : .ypWhite,
				radius: 10
			)
			.offset(y: 8)
		}
		.padding(.horizontal, 8)
		.padding(.trailing, 4)
		.padding(.bottom)
		.background(
			RoundedRectangle(cornerRadius: isImageDissapeared ? 0 : 0)
				.fill(.ultraThinMaterial)
				.shadow(color: .ypBlackUniversal.opacity(0.3), radius: 10)
				.opacity(isImageDissapeared ? 1 : 0)
				.ignoresSafeArea(edges: .top)
		)
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
	NFTDetailToolbarView(
		model: .mock,
		isImageFullScreen: .constant(false),
		isImageDissapeared: false,
		backAction: {},
		didTapLikeButton: {},
		modelUpdateTriggerID: .init()
	)
}
#endif
