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
	let model: UserListItemResponse
	private let api: ObservedNetworkClient
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
		push(
			.statNFTCollection(
				nftsIDs: model.nftsIDs,
				authorID: model.id,
				authorWebsiteURLString: model.websiteURLString
			)
		)
	}
	
	func didTapAuthLinkButton() {
		push(.aboutAuthor(urlString: model.websiteURLString))
	}
}
