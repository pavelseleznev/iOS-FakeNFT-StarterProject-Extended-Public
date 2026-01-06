//
//  StatisticsProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

struct StatisticsProfileView: View {
	@State private var viewModel: StatisticsProfileViewModel
	
	private let nftsIDsCount: Int
	
	init(
		api: ObservedNetworkClient,
		push: @escaping (Page) -> Void,
		model: UserListItemResponse
	) {
		_viewModel = .init(initialValue: .init(api: api, model: model, push: push))
		nftsIDsCount = model.nftsIDs.count
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			ProfileContainer(
				model: viewModel.model,
				link: {
					Button(.goToUserSite, action: viewModel.didTapAuthLinkButton)
						.nftButtonStyle(filled: false)
				},
				actions: {
					[
						ProfileActionCell(
							title: .nftCollection(count: nftsIDsCount)
						) {
							viewModel.didTapProfileActionCell()
						}
					]
				}
			)
			.safeAreaPadding(.top)
		}
	}
}

#if DEBUG
#Preview {
	StatisticsProfileView(
		api: .mock,
		push: {_ in},
		model: .mock
	)
}
#endif
