//
//  StatisticsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import Observation

@MainActor
@Observable
final class StatisticsViewModel {
	private(set) var users: [UserListItemResponse] = [
		.mock,
		.mock,
		.mock,
		.mock,
		.mock,
		.mock,
		.mock,
		.mock
	]
	private let api: ObservedNetworkClient
	private let push: (Page) -> Void
	
	init(
		api: ObservedNetworkClient,
		push: @escaping (Page) -> Void
	) {
		self.api = api
		self.push = push
	}
	
	func viewDidAppear() {}
}

extension StatisticsViewModel {
	func applySortByName() {}
	func applySortByRate() {}
	
	func didTapUserCell(for user: UserListItemResponse) {
		push(.statProfile(profile: user))
	}
}
