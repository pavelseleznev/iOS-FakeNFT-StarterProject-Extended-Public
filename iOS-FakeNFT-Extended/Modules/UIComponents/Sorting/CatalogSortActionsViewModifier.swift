//
//  CatalogSortActionsViewModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct CatalogSortActionsViewModifier: ViewModifier {
    enum SortOption: String {
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
    
    let placement: BaseConfirmationDialogTriggerPlacement
	@Binding var searchText: String
    @Binding var activeSortOption: SortOption
    
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
                            Button(.byTitle) {
                                activeSortOption = .name
                            }
                            Button(.byNFTQuantity) {
                                activeSortOption = .nftCount
                            }
                            Button(.close, role: .cancel) {}
                        }
                    }
                )
            )
    }
}
