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
		placement: BaseConfirmationDialogTriggerPlacement,
		didTapCost: @escaping () -> Void,
		didTapRate: @escaping () -> Void,
		didTapName: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				ProfileSortActionsViewModifier(
                    activeSortOption: activeSortOption,
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
		didTapName: @escaping () -> Void,
		didTapNFTCount: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				CatalogSortActionsViewModifier(
					placement: placement,
					didTapName: didTapName,
					didTapNFTCount: didTapNFTCount
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
    @Previewable @State var option: ProfileSortActionsViewModifier.SortOption = .name
    
	ZStack {
		Color.ypWhite.ignoresSafeArea()
	}
	.applyProfileSort(
        activeSortOption: $option,
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
			didTapName: {},
			didTapNFTCount: {}
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
