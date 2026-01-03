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
	
	@State private var activeSortOption: SortOption = .name
	
	let placement: BaseConfirmationDialogTriggerPlacement
	let didTapCost: () -> Void
	let didTapRate: () -> Void
	let didTapName: () -> Void
	
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
								didTapCost()
								activeSortOption = .cost
							}
							Button(.byRating) {
								didTapRate()
								activeSortOption = .rate
							}
							Button(.byTitle) {
								didTapName()
								activeSortOption = .name
							}
							Button(.close, role: .cancel) {}
						}
					}
				)
			)
	}
}
