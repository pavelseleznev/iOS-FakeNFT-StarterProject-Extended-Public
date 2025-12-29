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
        var description: String {
            switch self {
            case .name:
                "По названию"
            case .nftCount:
                "По кол-ву NFT"
            }
        }
    }
    
    let placement: BaseConfirmationDialogTriggerPlacement
    @Binding var activeSortOption: SortOption
    
    func body(content: Content) -> some View {
        content
            .modifier(
                BaseConfirmationDialogViewModifier(
                    placement: placement,
                    title: "Сортировка",
                    activeSortOption: activeSortOption.description,
                    actions: {
                        Group {
                            Button("По названию") {
                                activeSortOption = .name
                            }
                            Button("По количеству NFT") {
                                activeSortOption = .nftCount
                            }
                            Button("Закрыть", role: .cancel) {}
                        }
                    }
                )
            )
    }
}
