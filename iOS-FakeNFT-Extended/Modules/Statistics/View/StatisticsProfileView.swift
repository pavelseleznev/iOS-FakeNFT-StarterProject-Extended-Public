//
//  StatisticsProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

struct StatisticsProfileView: View {
	@State private var viewModel: StatisticsProfileViewModel
	private let nftsCount: Int
	
	init(
		api: ObservedNetworkClient,
		push: @escaping (Page) -> Void,
		model: UserListItemResponse
	) {
		self.nftsCount = model.nftsIDs.count
		_viewModel = .init(initialValue: .init(api: api, model: model, push: push))
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			ProfileContainer(
				model: .mock,
				link: {
					Button("Перейти на сайт пользователя"){
						viewModel.didTapAuthLinkButton()
					}
					.nftButtonStyle(filled: false)
				},
				actions: {
					[
						ProfileActionCell(title: "Коллекция NFT (\(nftsCount))") {
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
