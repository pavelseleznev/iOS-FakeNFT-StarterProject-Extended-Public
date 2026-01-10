//
//  PhotoURLAlertModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/16/25.
//

import SwiftUI

struct AlertPhotoURLModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var photoURL: String

    let title: LocalizedStringResource
    let placeholder: String
    let onSave: () -> Void

    @FocusState private var textFieldFocused: Bool
	@Environment(\.colorScheme) private var theme

    func body(content: Content) -> some View {
        ZStack {
            content
				.brightness(contentBrightness)
				.allowsHitTesting(!isPresented)
			
			GeometryReader { geo in
				if isPresented {
					VStack(spacing: 0) {
						Text(title)
							.font(.bold22)
							.padding(.top)
						
						TextField(placeholder, text: $photoURL)
							.autocorrectionDisabled(true)
							.textInputAutocapitalization(.never)
							.font(.bold17)
							.padding()
							.background(.regularMaterial, in: .capsule)
							.shadow(
								color: .ypBlackUniversal.opacity(0.1),
								radius: 4
							)
							.padding()
							.padding(.bottom, 8)
						
						Divider()
						HStack(spacing: 0) {
							Button {
								isPresented = false
							} label: {
								HStack {
									Spacer()
									Text(.cancel).font(.bold17)
									Spacer()
								}
							}
							.padding(.vertical)
							
							Divider()
							
							Button {
								onSave()
								isPresented = false
							} label: {
								HStack {
									Spacer()
									Text(.save).font(.bold17)
									Spacer()
								}
							}
							.disabled(photoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
							.padding(.vertical)
						}
						.frame(height: 60)
					}
					.background(.bar)
					.clipShape(.buttonBorder)
					.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 15)
					.frame(
						width: geo.size.width * 0.8,
						height: geo.size.height * 0.4
					)
					.position(
						x: geo.frame(in: .local).midX,
						y: geo.frame(in: .local).midY
					)
					.transition(
						.asymmetric(
							insertion: .scale.combined(with: .opacity).animation(.default),
							removal: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.15))
						)
					)
				}
            }
        }
		.animation(.default, value: isPresented)
    }
	
	private var contentBrightness: CGFloat {
		if theme == .dark {
			isPresented ? 0.2 : 0
		} else {
			isPresented ? -0.1 : 0
		}
	}
}

#Preview {
	@Previewable @State var isPresented = false
	@Previewable @State var urlString = ""
	
	Color.ypWhite.ignoresSafeArea()
		.modifier(
			AlertPhotoURLModifier(
				isPresented: $isPresented,
				photoURL: $urlString,
				title: "Title",
				placeholder: "https://",
				onSave: {}
			)
		)
		.task {
			try? await Task.sleep(for: .seconds(1))
			isPresented.toggle()
		}
}
