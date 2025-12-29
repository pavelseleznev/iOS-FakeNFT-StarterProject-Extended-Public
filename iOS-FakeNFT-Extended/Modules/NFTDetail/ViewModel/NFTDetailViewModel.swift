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
	private let push: (Page) -> Void
	let appContainer: AppContainer
	let authorID: String
	let authorWebsiteURLString: String
	
	private(set) var model: NFTModelContainer
	private(set) var modelUpdateTriggerID = UUID()
	private var currencies = [String : CurrencyContainer?]()
	var currenciesLoadErrorIsPresented = false
	
	@inline(__always)
	var visibleCurrencies: [CurrencyContainer?] {
		currencies
			.sorted {
				$0.key.localizedStandardCompare($1.key) == .orderedAscending
			}
			.map(\.value)
	}
	
	init(
		appContainer: AppContainer,
		model: NFTModelContainer,
		authorID: String,
		authorWebsiteURLString: String,
		push: @escaping (Page) -> Void
	) {
		self.appContainer = appContainer
		self.push = push
		self.authorID = authorID
		self.authorWebsiteURLString = authorWebsiteURLString
		self.model = model
	}
}

// MARK: - NFTDetailViewModel Extensions

// --- internal helpers ---
extension NFTDetailViewModel {
	func loadCurrencies() async {
		do {
			let _currencies = try await appContainer.api.getCurrencies()
			_currencies.forEach {
				currencies[$0.id, default: nil] = nil
			}
			
			for currency in _currencies {
				let loadedCurrency = try await appContainer.api.getCurrency(by: currency.id)
				currencies[currency.id] = .init(
					currency: loadedCurrency,
					id: currency.id
				)
			}
		} catch {
			guard !(error is CancellationError) else { return }
			withAnimation(Constants.defaultAnimation) {
				currenciesLoadErrorIsPresented = true
			}
		}
	}
}

// --- internal actions ---
extension NFTDetailViewModel {
	func didTapDetail(model: NFTModelContainer) {
		push(
			.nftDetail(
				model: model,
				authorID: authorID,
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
