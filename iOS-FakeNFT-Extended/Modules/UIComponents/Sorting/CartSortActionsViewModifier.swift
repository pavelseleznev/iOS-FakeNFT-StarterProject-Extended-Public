//
//  StatisticsSortActionsViewModifier 2.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct CartSortActionsViewModifier: ViewModifier {
	enum SortOption: String {
		case cost, rate, name
		var description: LocalizedStringResource {
			switch self {
			case .cost:
				.byCost
			case .rate:
				.byRating
			case .name:
				.byTitle
			}
		}
		
		var parameter: String {
			switch self {
			case .cost:
				"cost,asc"
			case .rate:
				"rating,asc"
			case .name:
				"name,asc"
			}
		}
	}
	
	@Binding private var activeSortOption: SortOption
	@Binding private var searchText: String
	private let placement: BaseConfirmationDialogTriggerPlacement
	
	init(
		activeSortOption: Binding<SortOption>,
		searchText: Binding<String>,
		placement: BaseConfirmationDialogTriggerPlacement,
	) {
		self._activeSortOption = activeSortOption
		self._searchText = searchText
		self.placement = placement
	}
	
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
							Button(.byCost) {
								activeSortOption = .cost
							}
							Button(.byRating) {
								activeSortOption = .rate
							}
							Button(.byTitle) {
								activeSortOption = .name
							}
							Button(.close, role: .cancel) {}
						}
					}
				)
			)
	}
}
