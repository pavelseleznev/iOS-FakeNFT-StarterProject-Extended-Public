//
//  StatisticsSortActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct StatisticsSortActionsViewModifier: ViewModifier {
	enum SortOption: String {
		case rate, name
		var description: LocalizedStringResource {
			switch self {
			case .rate:
				.byRating
			case .name:
				.byName
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
	@Binding var searchText: String
	
	let placement: BaseConfirmationDialogTriggerPlacement
	
	func body(content: Content) -> some View {
		content
			.modifier(
				BaseConfirmationDialogViewModifier(
					needsSearchBar: true,
					searchText: $searchText,
					placement: placement,
					title: .sorting,
					activeSortOption: activeSortOption.description,
					actions: {
						Group {
							Button(.byName) {
								activeSortOption = .name
							}
							Button(.byRating) {
								activeSortOption = .rate
							}
							Button(.close, role: .cancel) {}
						}
					}
				)
			)
	}
}
