//
//  CatalogSortActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct CatalogSortActionsViewModifier: ViewModifier {
	private enum SortOption {
		case name, nftCount
		var description: LocalizedStringResource {
			switch self {
			case .name:
				.byTitle
			case .nftCount:
				.byNFTQuantity
			}
		}
	}
	
	@State private var activeSortOption: SortOption = .name
	
	let placement: BaseConfirmationDialogTriggerPlacement
	let didTapName: () -> Void
	let didTapNFTCount: () -> Void
	
	func body(content: Content) -> some View {
		content
			.modifier(
				BaseConfirmationDialogViewModifier(
					placement: placement,
					title: .sorting,
					activeSortOption: activeSortOption.description,
					actions: {
						Group {
							Button(.byTitle) {
								didTapName()
								activeSortOption = .name
							}
							Button(.byNFTQuantity) {
								didTapNFTCount()
								activeSortOption = .nftCount
							}
							Button(.close, role: .cancel) {}
						}
					}
				)
			)
	}
}
