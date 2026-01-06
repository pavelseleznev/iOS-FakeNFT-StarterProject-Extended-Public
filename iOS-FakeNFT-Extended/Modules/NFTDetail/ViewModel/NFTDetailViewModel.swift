//
//  NFTDetailViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 25.12.2025.
//

import SwiftUI

@Observable
@MainActor
final class NFTDetailViewModel {
	private let currenciesService: CurrenciesServiceProtocol
	private let push: (Page) -> Void
	@ObservationIgnored
	private let screenID = UUID()
	let authorCollection: [Dictionary<String, NFTModelContainer?>.Element]
	
	let authorID: String
	let authorWebsiteURLString: String
	
	private(set) var model: NFTModelContainer
	private(set) var modelUpdateTriggerID = UUID()
	private(set) var currencies = [CurrencyContainer]()
	
	init(
		currenciesService: CurrenciesServiceProtocol,
		model: NFTModelContainer,
		authorID: String,
		authorCollection: [Dictionary<String, NFTModelContainer?>.Element],
		authorWebsiteURLString: String,
		push: @escaping (Page) -> Void
	) {
		self.currenciesService = currenciesService
		self.push = push
		self.authorID = authorID
		self.authorCollection = authorCollection
		self.authorWebsiteURLString = authorWebsiteURLString
		self.model = model
	}
}

// MARK: - NFTDetailViewModel Extensions

// --- internal helpers ---
extension NFTDetailViewModel {
	func loadCurrencies() async {
		currencies = await currenciesService.get()
	}
	
	func updateCurrencies(_ notfication: Notification) {
		guard let currencies = notfication.userInfo?["currencies"] as? [CurrencyContainer] else { return }
		self.currencies = currencies
	}
}

// --- internal actions ---
extension NFTDetailViewModel {
	func didTapDetail(model: NFTModelContainer) {
		push(
			.nftDetail(
				model: model,
				authorID: authorID,
				authorCollection: authorCollection,
				authorWebsiteURLString: authorWebsiteURLString
			)
		)
	}
	
	func didTapGoToSellerSite() {
		push(.aboutAuthor(urlString: authorWebsiteURLString))
	}
	
	func didTapCartButton() {
		changeModelState(isCartChanged: true)
	}
	
	func didTapLikeButton() {
		changeModelState(isFavoriteChanged: true)
	}
}

// --- private helpers ---
private extension NFTDetailViewModel {
	func changeModelState(
		isFavoriteChanged: Bool = false,
		isCartChanged: Bool = false
	) {
		model = .init(
			nft: model.nft,
			isFavorite: isFavoriteChanged ? !model.isFavorite : model.isFavorite,
			isInCart: isCartChanged ? !model.isInCart : model.isInCart
		)
		
		withAnimation(Constants.defaultAnimation) {
			modelUpdateTriggerID = .init()
		}
		
		sendUpdateNotification(
			nftID: model.id,
			isCartChanged: isCartChanged,
			isFavoriteChanged: isFavoriteChanged
		)
	}
	
	func sendUpdateNotification(
		nftID: String,
		isCartChanged: Bool = false,
		isFavoriteChanged: Bool = false
	) {
		let payload = NFTUpdatePayload(
			id: nftID,
			screenID: screenID,
			isCartChanged: isCartChanged,
			isFavoriteChanged: isFavoriteChanged,
			fromObject: .nftDetail
		)
		
		NotificationCenter
			.default
			.post(
				name: .nftDidChange,
				object: nil,
				userInfo: [Constants.nftChangePayloadKey : payload]
			)
	}
}
