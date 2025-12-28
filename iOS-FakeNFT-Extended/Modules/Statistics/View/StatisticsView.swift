//
//  StatisticsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct StatisticsView: View {
	private static let statisticsSortOptionKey: String = "statisticsSortOptionKey"
	
	@State private var viewModel: StatisticsViewModel
	@AppStorage(statisticsSortOptionKey) private var sortOption: StatisticsSortActionsViewModifier.SortOption = .rate
	
	init(
		api: ObservedNetworkClient,
		push: @escaping (Page) -> Void
	) {
		_viewModel = .init(
			initialValue: .init(
				api: api,
				push: push
			)
		)
		
		viewModel.setSortOption(sortOption)
	}
	
	var body: some View {
		ZStack(alignment: .top) {
			Color.ypWhite.ignoresSafeArea()
			
			List(Array(viewModel.visibleUsers.enumerated()), id: \.offset) { counter, user in
				UserListCell(model: user, counter: counter)
					.id(user.id)
					.task(priority: .userInitiated) {
						if user == viewModel.visibleUsers.last {
							await viewModel.loadNextUsersPage()
						}
					}
					.onTapGesture {
						viewModel.didTapUserCell(for: user)
					}
					.listRowSeparator(.hidden)
					.listRowInsets(.init())
					.listRowBackground(Color.clear)
					.padding(.horizontal)
			}
			.scrollIndicators(.hidden)
			.safeAreaPadding(.bottom)
			.listRowSpacing(8)
			.scrollContentBackground(.hidden)
			.listStyle(.plain)
			.animation(Constants.defaultAnimation, value: viewModel.visibleUsers)
			.overlay(content: loadingView)
		}
		.task(priority: .userInitiated) {
			await viewModel.loadNextUsersPage(onAppear: true)
		}
		.safeAreaTopBackground()
		.applyStatisticsSort(
			placement: .safeAreaTop,
			activeSortOption: $sortOption
		)
		.onChange(of: sortOption) { viewModel.setSortOption(sortOption) }
		.applyRepeatableAlert(
			isPresneted: $viewModel.dataLoadingErrorIsPresented,
			message: .cantGetUsersData,
			didTapRepeat: {
				Task(priority: .userInitiated) {
					await viewModel.loadNextUsersPage()
				}
			}
		)
	}
	
	private func loadingView() -> some View {
		LoadingView(loadingState: viewModel.loadingState)
	}
}

#if DEBUG
#Preview {
	@Previewable let obsAPI: ObservedNetworkClient = {
		let api = DefaultNetworkClient()
		return .init(api: api)
	}()
	
	StatisticsView(
		api: .mock,
		push: {_ in}
	)
}
#endif
