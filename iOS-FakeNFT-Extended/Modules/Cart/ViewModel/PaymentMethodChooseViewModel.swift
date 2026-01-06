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
	private let currenciesService: CurrenciesServiceProtocol
	private let cartService: CartServiceProtocol
	private let onComplete: () -> Void
	
	private(set) var currencies = [CurrencyContainer]()
	private(set) var selectedCurrency: CurrencyContainer?
	private(set) var paymentInProgress = false
	var alertIsPresented = false
	
	init(
		currenciesService: CurrenciesServiceProtocol,
		cartService: CartServiceProtocol,
		onComplete: @escaping () -> Void,
	) {
		self.currenciesService = currenciesService
		self.cartService = cartService
		self.onComplete = onComplete
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
		currencies = await currenciesService.get()
	}
	
	func updatePaymentMethods(_ notification: Notification) {
		guard let currencies = notification.userInfo?["currencies"] as? [CurrencyContainer] else { return }
		self.currencies = currencies
	}
	
	func didTapBuyButton() {
		Task(priority: .userInitiated) {
			do {
				paymentInProgress = true
				guard let selectedCurrency else {
					throw NSError(domain: "Currency is nil", code: 0, userInfo: nil)
				}

				try await cartService.pay(usingCurrencyID: selectedCurrency.id)
				
				onComplete()
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
