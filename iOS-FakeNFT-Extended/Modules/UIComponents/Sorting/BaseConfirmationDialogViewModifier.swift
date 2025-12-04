//
//  BaseConfirmationDialogViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct BaseConfirmationDialogViewModifier<Actions: View>: ViewModifier {
	@State private var isPresented = false
	
	let title: String
	let activeSortOption: String
	let actions: () -> Actions
	
	private let animation: Animation = .easeInOut(duration: 0.1)
	
	func body(content: Content) -> some View {
		NavigationStack {
			content
				.confirmationDialog(
					title,
					isPresented: $isPresented,
					actions: actions
				)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button {
							withAnimation(animation) {
								isPresented.toggle()
							}
						} label: {
							Text(activeSortOption)
								.foregroundStyle(.ypGreenUniversal)
								.contentTransition(.numericText())
								.font(.medium10)
						}
						.buttonStyle(.plain)
					}
					ToolbarItem(placement: .confirmationAction) {
						ToolbarSortButton(action: {
							withAnimation(animation) {
								isPresented.toggle()
							}
						})
					}
				}
				.animation(animation, value: activeSortOption)
		}
	}
}
