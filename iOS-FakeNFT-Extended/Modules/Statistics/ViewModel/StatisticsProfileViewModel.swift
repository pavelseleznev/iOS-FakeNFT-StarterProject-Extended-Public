//
//  StatisticsProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import Observation

@MainActor
@Observable
final class StatisticsProfileViewModel {
	private let api: ObservedNetworkClient
	private let model: UserListItemResponse
	private let push: (Page) -> Void
	
	init(
		api: ObservedNetworkClient,
		model: UserListItemResponse,
		push: @escaping (Page) -> Void
	) {
		self.api = api
		self.model = model
		self.push = push
	}
	
	func didTapProfileActionCell() {
		#warning("TODO: replace later wuth fetching from API")
		push(
			.statNFTCollection(
				nfts: [
					.mock,
					.mock,
					.badImageURLMock,
					.mock
				]
			)
		)
	}
	
	func didTapAuthLinkButton() {
		push(.aboutAuthor(urlString: model.websiteURLString))
	}
}
