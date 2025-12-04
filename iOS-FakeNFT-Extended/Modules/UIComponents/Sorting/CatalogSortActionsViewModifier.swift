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
		var description: String {
			switch self {
			case .name:
				"По названию"
			case .nftCount:
				"По кол-ву NFT"
			}
		}
	}
	
	@State private var activeSortOption: SortOption = .name
	
	let didTapName: () -> Void
	let didTapNFTCount: () -> Void
	
	func body(content: Content) -> some View {
		content
			.modifier(
				BaseConfirmationDialogViewModifier(
					title: "Сортировка",
					activeSortOption: activeSortOption.description,
					actions: {
						Group {
							Button("По названию") {
								didTapName()
								activeSortOption = .name
							}
							Button("По количеству NFT") {
								didTapNFTCount()
								activeSortOption = .nftCount
							}
							Button("Закрыть", role: .cancel) {}
						}
					}
				)
			)
	}
}
