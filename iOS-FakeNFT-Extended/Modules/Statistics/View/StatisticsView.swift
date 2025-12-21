//
//  StatisticsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct StatisticsView: View {
	@State private var viewModel: StatisticsViewModel
	
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
	}
	
	var body: some View {
		ZStack(alignment: .top) {
			Color.ypWhite.ignoresSafeArea()
			
			List(Array(viewModel.visibleUsers.enumerated()), id: \.offset) { counter, user in
				UserListCell(model: user, counter: counter)
					.task {
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
			.animation(.easeInOut(duration: 0.15), value: viewModel.visibleUsers)
		}
		.task {
			await viewModel.loadNextUsersPage(onAppear: true)
		}
		.safeAreaTopBackground()
		.applyStatisticsSort(
			placement: .safeAreaTop,
			activeSortOption: $viewModel.currenctSortOption
		)
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
