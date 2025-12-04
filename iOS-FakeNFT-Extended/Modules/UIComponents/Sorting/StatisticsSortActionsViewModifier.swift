//
//  StatisticsSortActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct StatisticsSortActionsViewModifier: ViewModifier {
	private enum SortOption {
		case rate, name
		var description: String {
			switch self {
			case .rate:
				"По рейтингу"
			case .name:
				"По названию"
			}
		}
	}
	
	@State private var activeSortOption: SortOption = .name
	
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
