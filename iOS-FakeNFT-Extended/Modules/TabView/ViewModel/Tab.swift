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
	case shoppingCart
	case statistics
	
	var title: String {
		switch self {
		case .profile:
			"Профиль"
		case .catalog:
			"Каталог"
		case .shoppingCart:
			"Корзина"
		case .statistics:
			"Статистика"
		}
	}
	
	var systemImageName: String {
		switch self {
		case .profile:
			"person.crop.circle.fill"
		case .catalog:
			"rectangle.stack.fill"
		case .shoppingCart:
			"handbag.fill"
		case .statistics:
			"flag.2.crossed.fill"
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
			ReplaceThisViewIsteadOfYours(
				appContainer: appContainer,
				push: push,
				present: present,
				dismiss: dismiss,
				title: title
			)
		case .catalog:
			ReplaceThisViewIsteadOfYours(
				appContainer: appContainer,
				push: push,
				present: present,
				dismiss: dismiss,
				title: title
			)
		case .shoppingCart:
			ReplaceThisViewIsteadOfYours(
				appContainer: appContainer,
				push: push,
				present: present,
				dismiss: dismiss,
				title: title
			)
		case .statistics:
			ReplaceThisViewIsteadOfYours(
				appContainer: appContainer,
				push: push,
				present: present,
				dismiss: dismiss,
				title: title
			)
		}
	}
	
	var id: Self { self }
}
