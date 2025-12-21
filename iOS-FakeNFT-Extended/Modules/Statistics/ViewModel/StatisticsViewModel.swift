//
//  StatisticsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class StatisticsViewModel {
	private(set) var users = Set<UserListItemResponse>()
	private let api: ObservedNetworkClient
	private let push: (Page) -> Void
	private var currentPage = 0
	
	var currenctSortOption: StatisticsSortActionsViewModifier.SortOption = .name
	
	init(
		api: ObservedNetworkClient,
		push: @escaping (Page) -> Void
	) {
		self.api = api
		self.push = push
	}
}

extension StatisticsViewModel {
	@inline(__always)
	var visibleUsers: [UserListItemResponse] {
		users
			.sorted(by: usersSortComparator)
	}
	
	func didTapUserCell(for user: UserListItemResponse) {
		push(.statProfile(profile: user))
	}
	
	@Sendable
	func loadNextUsersPage(onAppear: Bool = false) async {
		guard (onAppear && currentPage == 0) || !onAppear else { return }
		do {
			try await api
				.getUsers(page: currentPage, sortOption: currenctSortOption)
				.forEach {
					users.insert($0)
				}
			currentPage += 1
		} catch {
			print(error)
		}
	}
}

private extension StatisticsViewModel {
	func usersSortComparator(_ first: UserListItemResponse, _ second: UserListItemResponse) -> Bool {
		switch currenctSortOption {
		case .rate:
			first.rating.localizedStandardCompare(second.rating) == .orderedAscending
		case .name:
			first.name.localizedStandardCompare(second.name) == .orderedAscending
		}
	}
}
