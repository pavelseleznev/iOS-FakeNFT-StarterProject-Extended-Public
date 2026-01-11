//
//  ProfilePhotoActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct ProfilePhotoActionsViewModifier: ViewModifier {
	let isPresented: Binding<Bool>
	let didTapChangePhoto: () -> Void
	let didTapDeletePhoto: () -> Void
	
	func body(content: Content) -> some View {
		content
			.confirmationDialog(
				.profilePhoto,
				isPresented: isPresented,
				titleVisibility: .visible,
				actions: {
					Button(.changePhoto, action: didTapChangePhoto)
					Button(.deletePhoto, role: .destructive, action: didTapDeletePhoto)
					Button(.cancel, role: .cancel) {}
				}
			)
	}
}
