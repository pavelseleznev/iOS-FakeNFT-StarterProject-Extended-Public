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
	
	private let imageLoader = ImageLoadingWithCacheService.shared
	private let api: ObservedNetworkClient
	private let push: (Page) -> Void
	
	private var users = [UserListItemResponse]()
	
	private(set) var isRefreshing = false
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

// MARK: - StatisticsViewModel Extensions
// --- internal helpers ---
extension StatisticsViewModel {
	var visibleUsers: [UserListItemResponse] {
		users
			.filter(filterApplier)
	}
	
	@inline(__always)
	var loadingState: LoadingState {
		isRefreshing ? .idle : api.loadingState
	}
	
	func didTapUserCell(for user: UserListItemResponse) {
		push(.statistics(.profile(profile: user)))
	}
	
	func onDebounce(_ searchText: String) {
		self.searchText = searchText
	}
	
	@Sendable
	func loadNextUsersPage(onAppear: Bool = false) async {
		guard (onAppear && currentPage == 0) || !onAppear else { return }
		do {
			let newUsers = try await api
				.getUsers(page: currentPage, sortOption: currenctSortOption)
				.sorted(by: usersSortComparator)
				.filter(filterApplier)
			
			users.append(contentsOf: newUsers)
			currentPage += 1
		} catch { onError(error) }
	}
	
	@Sendable
	func resetUsers() async {
		guard !users.isEmpty else { return }
		
		if visibleUsers.count < 9 { // on search filter active | load more
			await loadNextUsersPage()
			return
		}
		
		isRefreshing = true
		
		defer { isRefreshing = false }

		guard currentPage > 0 else {
			users.sort(by: usersSortComparator)
			return
		}
		currentPage = 0
		users = []
		await loadNextUsersPage()
	}
	
	func setSortOption(_ option: SortOption) {
		currenctSortOption = option
		Task(priority: .userInitiated) {
			await resetUsers()
		}
	}
}

// --- private helpers ---
private extension StatisticsViewModel {
	func usersSortComparator(_ lhs: UserListItemResponse, _ rhs: UserListItemResponse) -> Bool {
		switch currenctSortOption {
		case .rate:
			return lhs.rating.localizedStandardCompare(rhs.rating) == .orderedDescending
		case .name:
			let lhsPriority = comparatorPriority(lhs.name)
			let rhsPriority = comparatorPriority(rhs.name)
			
			if lhsPriority != rhsPriority {
				return lhsPriority < rhsPriority
			}
			
			return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
		}
	}
	
	func filterApplier(_ model: UserListItemResponse) -> Bool {
		searchText.isEmpty || model.name.localizedCaseInsensitiveContains(searchText)
	}
	
	func onError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(Constants.defaultAnimation) {
			dataLoadingErrorIsPresented = true
		}
	}
}
