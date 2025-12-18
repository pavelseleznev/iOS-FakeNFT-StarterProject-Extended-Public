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
	case statistics
	
	var title: String {
		switch self {
		case .profile:
			"Профиль"
		case .catalog:
			"Каталог"
		case .statistics:
			"Статистика"
		}
	}
	
	@ViewBuilder
	func imageView() -> some View {
		switch self {
		case .profile:
			Image.profilePerson
		case .catalog:
			Image.catalog
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
                profile: appContainer.profileProvider.profile(),
                router: TabProfileRouter(push: push)
			)
		case .catalog:
			CatalogView(
				appContainer: appContainer,
				push: push
			)
		case .statistics:
			StatisticsView(
				appContainer: appContainer,
				push: push
			)
		}
	}
	
	var id: Self { self }
}
