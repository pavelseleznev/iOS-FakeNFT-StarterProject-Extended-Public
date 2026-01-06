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
	@State private var clearTextFieldIsPresented = false
	
	@Binding private var searchText: String
	private let needsSearchBar: Bool
	private let placement: BaseConfirmationDialogTriggerPlacement
	private let title: LocalizedStringResource
	private let activeSortOption: LocalizedStringResource
	private let actions: () -> Actions
	
	private let animation: Animation = .easeInOut(duration: 0.1)
	
	init(
		isPresented: Bool = false,
		needsSearchBar: Bool = false,
		searchText: Binding<String> = .constant(""),
		placement: BaseConfirmationDialogTriggerPlacement,
		title: LocalizedStringResource,
		activeSortOption: LocalizedStringResource,
		actions: @escaping () -> Actions
	) {
		self.isPresented = isPresented
		self._searchText = searchText
		self.needsSearchBar = needsSearchBar
		self.placement = placement
		self.title = title
		self.activeSortOption = activeSortOption
		self.actions = actions
	}
	
	func body(content: Content) -> some View {
		content
			.confirmationDialog(
				title,
				isPresented: $isPresented,
				titleVisibility: .visible,
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
			.animation(Constants.defaultAnimation, value: textMightBeCleared)
	}
	
	private var content: some View {
		VStack(spacing: 0) {
			HStack {
				Spacer()
				sortView
			}
			.offset(x: placement == .toolbar ? 8 : 0)
			.padding(.trailing, placement == .safeAreaTop ? 8 : 0)
			.padding(.leading)
			
			searchBar
		}
	}
	
	private var textMightBeCleared: Bool {
		searchText.isEmpty
	}
}

// MARK: - BaseConfirmationDialogViewModifier Extensions
// --- builders ---
private extension BaseConfirmationDialogViewModifier {
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
				.padding(.bottom, 32)
		}
	}
}

// --- bar items ---
private extension BaseConfirmationDialogViewModifier {
	@ViewBuilder
	private var searchBar: some View {
		if needsSearchBar {
			TextField(text: $searchText) {
				Text(.search)
			}
			.font(.regular17)
			.padding(.horizontal, 22)
			.overlay(alignment: .leading) {
				Image(systemName: "magnifyingglass")
					.font(.regular15)
					.foregroundStyle(.ypGrayUniversal)
			}
			.overlay(alignment: .trailing) {
				if !textMightBeCleared {
					Button {
						searchText = ""
					} label: {
						Image.xmark
							.symbolVariant(.circle)
							.symbolVariant(.fill)
							.font(.regular15)
							.foregroundStyle(.ypGrayUniversal)
					}
					.transition(.opacity.combined(with: .scale))
				}
			}
			.padding(6)
			.background(.quinary)
			.clipShape(RoundedRectangle(cornerRadius: 8))
			.padding(.horizontal)
			.textInputAutocapitalization(.never)
			.autocorrectionDisabled()
		}
	}
	
	private var sortView: some View {
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
}
