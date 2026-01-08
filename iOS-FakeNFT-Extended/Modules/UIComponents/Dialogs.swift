//
//  BottomAlertContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

extension View {
	func applyProfileSort(
        activeSortOption: Binding<ProfileSortActionsViewModifier.SortOption>,
		placement: BaseConfirmationDialogTriggerPlacement
	) -> some View {
		self
			.modifier(
				ProfileSortActionsViewModifier(
                    activeSortOption: activeSortOption,
					placement: placement
				)
			)
	}
	
	func applyCartSort(
		placement: BaseConfirmationDialogTriggerPlacement,
		activeSortOption: Binding<CartSortActionsViewModifier.SortOption>,
		searchText: Binding<String>
	) -> some View {
		self
			.modifier(
				CartSortActionsViewModifier(
					activeSortOption: activeSortOption,
					searchText: searchText,
					placement: placement
				)
			)
	}
	
	func applyStatisticsSort(
		placement: BaseConfirmationDialogTriggerPlacement,
		activeSortOption: Binding<StatisticsSortActionsViewModifier.SortOption>,
		searchText: Binding<String>
	) -> some View {
		self
			.modifier(
				StatisticsSortActionsViewModifier(
					activeSortOption: activeSortOption,
					searchText: searchText,
					placement: placement
				)
			)
	}
	
    func applyCatalogSort(
        placement: BaseConfirmationDialogTriggerPlacement,
        activeSortOption: Binding<CatalogSortActionsViewModifier.SortOption>,
		searchText: Binding<String>
    ) -> some View {
        self
            .modifier(
                CatalogSortActionsViewModifier(
                    placement: placement,
					searchText: searchText,
                    activeSortOption: activeSortOption
                )
            )
    }
	
	func applyProfilePhotoActions(
		isPresented: Binding<Bool>,
		didTapChangePhoto: @escaping () -> Void,
		didTapDeletePhoto: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				ProfilePhotoActionsViewModifier(
					isPresented: isPresented,
					didTapChangePhoto: didTapChangePhoto,
					didTapDeletePhoto: didTapDeletePhoto
				)
			)
	}
}

#if DEBUG
#Preview("Statistic") {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
	}
	.applyStatisticsSort(
		placement: .safeAreaTop,
		activeSortOption: .constant(.name),
		searchText: .constant("")
	)
}

#Preview("Profile Sort") {
    @Previewable @State var option: ProfileSortActionsViewModifier.SortOption = .name
    
	ZStack {
		Color.ypWhite.ignoresSafeArea()
	}
	.applyProfileSort(
        activeSortOption: $option,
		placement: .safeAreaTop
	)
}

#Preview("Catalog Sort") {
    NavigationStack {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
        }
        .applyCatalogSort(
            placement: .safeAreaTop,
            activeSortOption: .constant(.name),
			searchText: .constant("")
        )
    }
}

#Preview("Profile Image") {
	@Previewable @State var isPresented = false
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button("Toogle profile image actions presentation") {
			withAnimation {
				isPresented.toggle()
			}
		}
	}
	.applyProfilePhotoActions(
		isPresented: $isPresented,
		didTapChangePhoto: {},
		didTapDeletePhoto: {}
	)
}
#endif
