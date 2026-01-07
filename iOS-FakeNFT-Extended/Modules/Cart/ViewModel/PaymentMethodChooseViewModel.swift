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
		HapticPerfromer.shared.play(.notification(.error))
		
		withAnimation(Constants.defaultAnimation) {
			alertIsPresented = true
		}
	}
	
	func loadPaymentMethods() async {
		let newCurrencies = await currenciesService.get()
		
		guard newCurrencies != currencies else { return }
		HapticPerfromer.shared.play(.impact(.light))
		
		currencies = newCurrencies
	}
	
	func updatePaymentMethods(_ notification: Notification) {
		guard
			let newCurrencies = notification.userInfo?[Notification.Name.currenciesDidUpdate] as? [CurrencyContainer],
			newCurrencies != currencies
		else { return }
		
		self.currencies = currencies
	}
	
	func didTapBuyButton() {
		Task(priority: .userInitiated) {
			do {
				HapticPerfromer.shared.play(.impact(.medium))
				
				paymentInProgress = true
				guard let selectedCurrency else {
					throw NSError(domain: "Currency is nil", code: 0, userInfo: nil)
				}

				try await cartService.pay(usingCurrencyID: selectedCurrency.id)
				
				HapticPerfromer.shared.play(.notification(.success))
				
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
