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
	private let cartService: CartServiceProtocol
	private let push: (Page) -> Void
	
	private var currencies = [String : CurrencyContainer?]()
	private(set) var selectedCurrency: CurrencyContainer?
	private(set) var paymentInProgress = false
	var alertIsPresented = false
	
	init(
		cartService: CartServiceProtocol,
		push: @escaping (Page) -> Void,
	) {
		self.cartService = cartService
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
			let _currencies = try await cartService.loadCurrencies()
			
			_currencies.forEach { currencies[$0.id, default: nil] = nil }
			
			for currency in _currencies {
				let _currency = try await cartService.loadCurrency(byID: currency.id)
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

				try await cartService.pay(usingCurrencyID: selectedCurrency.id)
				
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
