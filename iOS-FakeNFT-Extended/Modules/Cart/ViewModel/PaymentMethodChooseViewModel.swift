//
//  PaymentMethodChooseViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

@Observable
@MainActor
final class PaymentMethodChooseViewModel {
	private let appContainer: AppContainer
	private let push: (Page) -> Void
	
	private var currencies = [String : CurrencyContainer?]()
	private(set) var selectedCurrency: CurrencyContainer?
	private(set) var paymentInProgress = false
	var alertIsPresented = false
	
	init(
		appContainer: AppContainer,
		push: @escaping (Page) -> Void,
	) {
		self.appContainer = appContainer
		self.push = push
	}
}

// MARK: - PaymentMethodChooseViewModel Extensions
// --- internal helpers ---
extension PaymentMethodChooseViewModel {
	private func onError(_ error: Error) {
		paymentInProgress = false
		
		guard !(error is CancellationError) else { return }
		withAnimation(Constants.defaultAnimation) {
			alertIsPresented = true
		}
	}
	
	func loadPaymentMethods() async {
		guard currencies.isEmpty else { return }
		
		do {
			let _currencies = try await appContainer.api
				.getCurrencies()
			
			_currencies.forEach { currencies[$0.id, default: nil] = nil }
			
			for currency in _currencies {
				let _currency = try await appContainer.api.getCurrency(by: currency.id)
				currencies[currency.id] = .init(
					currency: _currency,
					id: currency.id
				)
			}
		} catch {
			onError(error)
		}
	}
	
	func didTapBuyButton() {
		Task(priority: .userInitiated) {
			do {
				paymentInProgress = true
				guard let selectedCurrency else {
					throw NSError(domain: "Currency is nil", code: 0, userInfo: nil)
				}

				let result = try await appContainer.api.setCurrency(id: selectedCurrency.id)
				guard result.isSuccess else {
					throw NSError(domain: "Failed to set currency", code: 0, userInfo: nil)
				}
				
				let nftsIDs = await appContainer.nftService.getAllCart()
				for nftID in nftsIDs {
					try await appContainer.api.pay(payload: .init(nfts: nftID))
				}
				
				await appContainer.nftService.didPurchase(ids: nftsIDs)
				await appContainer.nftService.clearCart()
				
				push(.successPayment)
			} catch {
				onError(error)
			}
		}
	}
	
	func setCurrency(_ currency: CurrencyContainer?) {
		withAnimation(.easeInOut(duration: 0.25)) {
			selectedCurrency = currency
		}
	}
}

// --- data getters ---
extension PaymentMethodChooseViewModel {
	var visibleCurrencies: [CurrencyContainer?] {
		currencies
			.sorted {
				$0.key.localizedStandardCompare($1.key) == .orderedAscending
			}
			.map(\.value)
	}
	
	var isLoaded: Bool {
		currencies.compactMap(\.value).count == currencies.count
	}
}
