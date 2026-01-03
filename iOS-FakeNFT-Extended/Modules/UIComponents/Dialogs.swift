//
//  BottomAlertContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

extension View {
	func applyProfileSort(
		placement: BaseConfirmationDialogTriggerPlacement,
		didTapCost: @escaping () -> Void,
		didTapRate: @escaping () -> Void,
		didTapName: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				ProfileSortActionsViewModifier(
					placement: placement,
					didTapCost: didTapCost,
					didTapRate: didTapRate,
					didTapName: didTapName
				)
			)
	}
	
	func applyStatisticsSort(
		placement: BaseConfirmationDialogTriggerPlacement,
		didTapName: @escaping () -> Void,
		didTapRate: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				StatisticsSortActionsViewModifier(
					placement: placement,
					didTapRate: didTapRate,
					didTapName: didTapName
				)
			)
	}
	
    func applyCatalogSort(
        placement: BaseConfirmationDialogTriggerPlacement,
        activeSortOption: Binding<CatalogSortActionsViewModifier.SortOption>
    ) -> some View {
        self
            .modifier(
                CatalogSortActionsViewModifier(
                    placement: placement,
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
		didTapName: {},
		didTapRate: {}
	)
}

#Preview("Profile Sort") {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
	}
	.applyProfileSort(
		placement: .safeAreaTop,
		didTapCost: {},
		didTapRate: {},
		didTapName: {}
	)
}

#Preview("Catalog Sort") {
    NavigationStack {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
        }
        .applyCatalogSort(
            placement: .safeAreaTop,
            activeSortOption: .constant(.name)
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
