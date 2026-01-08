//
//  ProfileSortActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct ProfileSortActionsViewModifier: ViewModifier {
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
	}
	
	@Binding var activeSortOption: SortOption
	
	let placement: BaseConfirmationDialogTriggerPlacement
	
	func body(content: Content) -> some View {
		content
			.modifier(
				BaseConfirmationDialogViewModifier(
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
