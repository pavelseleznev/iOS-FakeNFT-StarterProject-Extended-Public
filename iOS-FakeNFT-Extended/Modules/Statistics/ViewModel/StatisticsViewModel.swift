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
	
	private(set) var isRefreshing = false
	private var currentPage = 0
	var dataLoadingErrorIsPresented = false
	var searchText = ""
	
	var currenctSortOption: SortOption = .name
	
	private var updateTask: Task<Void, Never>?
	
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
		isRefreshing ? .idle : api.loadingState
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
		} catch { onError(error) }
	}
	
	@Sendable
	func updateUsers() async {
		guard !users.isEmpty else { return }
		
		withAnimation(Constants.defaultAnimation) {
			isRefreshing = true
		}
		
		defer {
			withAnimation(Constants.defaultAnimation) {
				isRefreshing = false
			}
		}
		
		do {
			var usersToRemove = Set<UserListItemResponse>()
			var usersToAdd = Set<UserListItemResponse>()
			
			for page in 0...currentPage - 1 {
				guard !Task.isCancelled, isRefreshing else { break }
				let pageUsers = Set(try await api.getUsers(page: page, sortOption: currenctSortOption))
				
				let pageToRemove = users.intersection(pageUsers).subtracting(
					pageUsers
				)
				let pageToAdd = pageUsers.subtracting(users)
				
				usersToRemove.formUnion(pageToRemove)
				usersToAdd.formUnion(pageToAdd)
			}
			
			if !usersToRemove.isEmpty || !usersToAdd.isEmpty {
				users.subtract(usersToRemove)
				users.formUnion(usersToAdd)
			}
		} catch { onError(error) }
	}
	
	func setSortOption(_ option: SortOption) {
		currenctSortOption = option
	}
}

private extension StatisticsViewModel {
	func usersSortComparator(_ lhs: UserListItemResponse, _ rhs: UserListItemResponse) -> Bool {
		switch currenctSortOption {
		case .rate:
			return lhs.rating.localizedStandardCompare(rhs.rating) == .orderedAscending
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
		searchText.isEmpty || model.name
			.localizedCaseInsensitiveContains(searchText)
	}
	
	func onError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(Constants.defaultAnimation) {
			dataLoadingErrorIsPresented = true
		}
	}
}
