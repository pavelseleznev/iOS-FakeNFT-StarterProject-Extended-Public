//
//  EditProfileHeader.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

fileprivate let imageSize: CGFloat = 120

struct EditProfileHeader: View {
    @Binding var isPhotoActionsPresented: Bool
	let avatarURLString: String
    let didTapChangePhoto: () -> Void
    let didTapDeletePhoto: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
			Group {
				if avatarURLString.isEmpty {
					placeholder
						.transition(.scale.combined(with: .opacity).animation(.default))
				} else {
					AsyncImageCached(urlString: avatarURLString) { phase in
						switch phase {
						case .empty, .error:
							Color.ypLightGrey
								.overlay {
									ProgressView()
										.progressViewStyle(.circular)
								}
						case .loaded(let uIImage):
							Image(uiImage: uIImage)
								.resizable()
						}
					}
					.transition(.scale.combined(with: .opacity).animation(.default))
				}
			}
			.scaledToFit()
			.frame(width: imageSize, height: imageSize)
			.clipShape(.circle)
            .modifier(
                ProfilePhotoActionsViewModifier(
                    isPresented: $isPhotoActionsPresented,
                    didTapChangePhoto: didTapChangePhoto,
                    didTapDeletePhoto: didTapDeletePhoto
                ))
            
			Image.frameCamera
                .resizable()
				.scaledToFit()
				.padding(imageSize * 0.1)
				.background(
					Circle()
						.fill(Material.thin)
						.strokeBorder(
							.ypBlack.opacity(0.4),
							lineWidth: 1
						)
				)
				.frame(width: imageSize * 0.4)
        }
		.onTapGesture {
			isPhotoActionsPresented = true
		}
    }
    private var placeholder: some View {
        Image.userPicturePlaceholder
            .resizable()
    }
}

#if DEBUG
#Preview {
	Color.ypWhite.ignoresSafeArea()
		.overlay {
			EditProfileHeader(
				isPhotoActionsPresented: .constant(false),
				avatarURLString: "",
				didTapChangePhoto: {},
				didTapDeletePhoto: {}
			)
		}
}
#endif
