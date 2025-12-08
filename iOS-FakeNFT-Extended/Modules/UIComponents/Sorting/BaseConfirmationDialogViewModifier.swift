//
//  BaseConfirmationDialogViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

enum BaseConfirmationDialogTriggerPlacement {
	case toolbar, safeAreaTop
}

struct BaseConfirmationDialogViewModifier<Actions: View>: ViewModifier {
	@State private var isPresented = false
	
	let placement: BaseConfirmationDialogTriggerPlacement
	let title: String
	let activeSortOption: String
	let actions: () -> Actions
	
	private let animation: Animation = .easeInOut(duration: 0.1)
	
	func body(content: Content) -> some View {
		content
			.confirmationDialog(
				title,
				isPresented: $isPresented,
				actions: actions
			)
			.toolbar {
				ToolbarItem(
					placement: .destructiveAction,
					content: toolbarContent
				)
			}
			.safeAreaInset(
				edge: .top,
				content: safeAreaTopContent
			)
			.animation(animation, value: activeSortOption)
	}
	
	private var content: some View {
		HStack {
			Spacer()
			HStack(spacing: 0) {
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
				
				RoundedRectangle(cornerRadius: 8)
					.fill(.ypBlack)
					.frame(width: 0.5, height: 20)
					.offset(x: placement == .toolbar ? 6 : 3)
				
				ToolbarSortButton(action: {
					withAnimation(animation) {
						isPresented.toggle()
					}
				})
			}
		}
		.offset(x: placement == .toolbar ? 8 : 0)
	}
	
	@ViewBuilder
	private func toolbarContent() -> some View {
		if case .toolbar = placement {
			content
		}
	}
	
	@ViewBuilder
	private func safeAreaTopContent() -> some View {
		if case .safeAreaTop = placement {
			content
				.padding([.bottom, .trailing], 8)
		}
	}
}
