//
//  Tab.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
	case profile
	case catalog
	case cart
	case statistics
	
	var title: LocalizedStringResource {
		switch self {
		case .profile:
			.profile
		case .catalog:
			.catalog
		case .cart:
			.cart
		case .statistics:
			.statistics
		}
	}
	
	var imageView: Image {
		switch self {
		case .profile:
			Image.profilePerson
		case .catalog:
			Image.catalog
		case .cart:
			Image.shoppingBag
		case .statistics:
			Image.statistics
		}
	}
	
	@MainActor
	@ViewBuilder
	func view(
		appContainer: AppContainer,
		push: @escaping (Page) -> Void,
		present: @escaping (Sheet) -> Void,
		dismiss: @escaping () -> Void
	) -> some View {
		switch self {
		case .profile:
			ProfileView(
				appContainer: appContainer,
				push: push
			)
			
		case .catalog:
			CatalogView(
				appContainer: appContainer,
				push: push
			)
			
		case .cart:
			CartView(
				nftService: appContainer.nftService,
				cartService: appContainer.cartService,
				onSubmit: { push(.cart(.paymentMethodChoose)) }
			)
			
		case .statistics:
			StatisticsView(
				api: .mock,
				push: push
			)
		}
	}
	
	var id: Self { self }
}
