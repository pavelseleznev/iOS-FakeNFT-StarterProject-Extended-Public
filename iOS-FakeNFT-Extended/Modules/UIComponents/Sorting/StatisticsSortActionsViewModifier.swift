//
//  StatisticsSortActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct StatisticsSortActionsViewModifier: ViewModifier {
	enum SortOption {
		case rate, name
		var description: String {
			switch self {
			case .rate:
				"По рейтингу"
			case .name:
				"По имени"
			}
		}
		
		var parameter: String {
			switch self {
			case .rate:
				"rating,asc"
			case .name:
				"name,asc"
			}
		}
	}
	
	@Binding var activeSortOption: SortOption
	
	let placement: BaseConfirmationDialogTriggerPlacement
	
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
								activeSortOption = .name
							}
							Button("По рейтингу") {
								activeSortOption = .rate
							}
							Button("Закрыть", role: .cancel) {}
						}
					}
				)
			)
	}
}
