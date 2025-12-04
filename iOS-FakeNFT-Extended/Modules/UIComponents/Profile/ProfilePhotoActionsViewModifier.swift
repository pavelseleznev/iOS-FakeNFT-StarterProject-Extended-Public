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
				"Фото профиля",
				isPresented: isPresented,
				titleVisibility: .visible,
				actions: {
					Button("Изменить фото", action: didTapChangePhoto)
					Button("Удалить фото", role: .destructive, action: didTapDeletePhoto)
					Button("Отмена", role: .cancel) {}
				}
			)
	}
}
