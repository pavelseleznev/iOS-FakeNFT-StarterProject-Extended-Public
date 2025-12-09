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
				"По имени"
			}
		}
	}
	
	@State private var activeSortOption: SortOption = .name
	
	let placement: BaseConfirmationDialogTriggerPlacement
	let didTapRate: () -> Void
	let didTapName: () -> Void
	
	func body(content: Content) -> some View {
		content
			.modifier(
				BaseConfirmationDialogViewModifier(
					placement: placement,
					title: "Сортировка",
					activeSortOption: activeSortOption.description,
					actions: {
						Group {
							Button("По имени") {
								didTapName()
								activeSortOption = .name
							}
							Button("По рейтингу") {
								didTapRate()
								activeSortOption = .rate
							}
							Button("Закрыть", role: .cancel) {}
						}
					}
				)
			)
	}
}
