//
//  BottomAlertContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

extension View {
	func applyProfileSort(
		didTapCost: @escaping () -> Void,
		didTapRate: @escaping () -> Void,
		didTapName: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				ProfileSortActionsViewModifier(
					didTapCost: didTapCost,
					didTapRate: didTapRate,
					didTapName: didTapName
				)
			)
	}
	
	func applyStatisticsSort(
		didTapName: @escaping () -> Void,
		didTapRate: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				StatisticsSortActionsViewModifier(
					didTapRate: didTapRate,
					didTapName: didTapName
				)
			)
	}
	
	func applyCatalogSort(
		didTapName: @escaping () -> Void,
		didTapNFTCount: @escaping () -> Void
	) -> some View {
		self
			.modifier(
				CatalogSortActionsViewModifier(
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
		didTapName: {},
		didTapRate: {}
	)
}

#Preview("Profile Sort") {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
	}
	.applyProfileSort(
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
