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
			
			List(Array(viewModel.users.enumerated()), id: \.offset) { counter, user in
				UserListCell(model: user, counter: counter)
					.onTapGesture {
						viewModel.didTapUserCell(for: user)
					}
					.listRowSeparator(.hidden)
					.listRowInsets(.init())
					.listRowBackground(Color.clear)
					.padding(.trailing, 16)
					.padding(.leading, 24)
			}
			.safeAreaPadding(.bottom)
			.listRowSpacing(8)
			.scrollContentBackground(.hidden)
			.listStyle(.plain)
		}
		.safeAreaTopBackground()
		.applyStatisticsSort(
			placement: .safeAreaTop,
			didTapName: viewModel.applySortByName,
			didTapRate: viewModel.applySortByRate
		)
		.onAppear(perform: viewModel.viewDidAppear)
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
