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
	
	@ObservationIgnored
	private var cartActionTask: Task<Void, Never>?
	@ObservationIgnored
	private var likeActionTask: Task<Void, Never>?
	
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
	
	func clearAllTasks() {
		clearCartActionTask()
		clearLikeActionTask()
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
		cartActionTask = changeModelState(
			updateTask: cartActionTask,
			clear: clearCartActionTask,
			invertInCartState: true,
			action: { @Sendable [weak self] in
				guard let self else { return }
				if await model.isInCart {
					await appContainer.nftService.removeFromCart(id: model.id)
				} else {
					await appContainer.nftService.addToCart(id: model.id)
				}
			}
		)
	}
	
	func didTapLikeButton() {
		likeActionTask = changeModelState(
			updateTask: likeActionTask,
			clear: clearLikeActionTask,
			invertFavouriteState: true,
			action: { @Sendable [weak self] in
				guard let self else { return }
				if await model.isFavorite {
					await appContainer.nftService.addToFavourite(id: model.id)
				} else {
					await appContainer.nftService.removeFromFavourite(id: model.id)
				}
			}
		)
	}
}

// --- private helpers ---
private extension NFTDetailViewModel {
	func clearCartActionTask() {
		cartActionTask?.cancel()
		cartActionTask = nil
	}
	
	func clearLikeActionTask() {
		likeActionTask?.cancel()
		likeActionTask = nil
	}
	
	func changeModelState(
		updateTask: Task<Void, Never>?,
		clear: @escaping () -> Void,
		invertFavouriteState: Bool = false,
		invertInCartState: Bool = false,
		action: @escaping () async -> Void
	) -> Task<Void, Never>? {
		guard updateTask == nil else { return updateTask }
		
		let task = Task(priority: .userInitiated) {
			defer { clear() }
			
			await action()
			
			model = .init(
				nft: model.nft,
				isFavorite: invertFavouriteState ? !model.isFavorite : model.isFavorite,
				isInCart: invertInCartState ? !model.isInCart : model.isInCart
			)
			
			withAnimation(.easeInOut(duration: 0.25)) {
				modelUpdateTriggerID = .init()
			}
		}
		
		return task
	}
}
