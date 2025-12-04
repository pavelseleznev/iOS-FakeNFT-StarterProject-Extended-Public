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
						Text(activeSortOption)
							.foregroundStyle(.ypGreenUniversal)
							.contentTransition(.numericText())
							.font(.medium10)
					}
					ToolbarItem(placement: .confirmationAction) {
						ToolbarSortButton(action: {
							withAnimation {
								isPresented.toggle()
							}
						})
					}
				}
				.animation(.easeInOut(duration: 0.1), value: activeSortOption)
		}
	}
}
