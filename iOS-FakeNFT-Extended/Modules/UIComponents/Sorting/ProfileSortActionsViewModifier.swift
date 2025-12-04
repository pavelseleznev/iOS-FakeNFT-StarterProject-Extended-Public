//
//  ProfileSortActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct ProfileSortActionsViewModifier: ViewModifier {
	private enum SortOption {
		case cost, rate, name
		var description: String {
			switch self {
			case .cost:
				"По цене"
			case .rate:
				"По рейтингу"
			case .name:
				"По названию"
			}
		}
	}
	
	@State private var activeSortOption: SortOption = .name
	
	let didTapCost: () -> Void
	let didTapRate: () -> Void
	let didTapName: () -> Void
	
	func body(content: Content) -> some View {
		content
			.modifier(
				BaseConfirmationDialogViewModifier(
					title: "Сортировка",
					activeSortOption: activeSortOption.description,
					actions: {
						Group {
							Button("По цене") {
								didTapCost()
								activeSortOption = .cost
							}
							Button("По рейтингу") {
								didTapRate()
								activeSortOption = .rate
							}
							Button("По названию") {
								didTapName()
								activeSortOption = .name
							}
							Button("Закрыть", role: .cancel) {}
						}
					}
				)
			)
	}
}
