//
//  StatisticsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

@MainActor
@Observable
final class StatisticsViewModel {
	typealias SortOption = StatisticsSortActionsViewModifier.SortOption
	
	private let api: ObservedNetworkClient
	private let push: (Page) -> Void
	
	private(set) var users = Set<UserListItemResponse>()
	
	private var currentPage = 0
	var dataLoadingErrorIsPresented = false
	var searchText = ""
	
	var currenctSortOption: SortOption = .name
	
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
	var loadingState: LoadingState {
		api.loadingState
	}
	
	@inline(__always)
	var visibleUsers: [UserListItemResponse] {
		users
			.sorted(by: usersSortComparator)
			.filter(filterApplier)
	}
	
	func didTapUserCell(for user: UserListItemResponse) {
		push(.statProfile(profile: user))
	}
	
	func onDebounce(_ searchText: String) {
		self.searchText = searchText
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
			guard !(error is CancellationError) else { return }
			withAnimation(Constants.defaultAnimation) {
				dataLoadingErrorIsPresented = true
			}
		}
	}
	
	func setSortOption(_ option: SortOption) {
		currenctSortOption = option
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
	
	func filterApplier(_ model: UserListItemResponse) -> Bool {
		searchText.isEmpty || model.name
			.localizedCaseInsensitiveContains(searchText)
	}
}
