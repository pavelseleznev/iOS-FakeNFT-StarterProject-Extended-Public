//
//  PaymentMethodChooseBottomBar.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct PaymentMethodChooseBottomBar: View {
	private let userAgreementURLString = "https://yandex.ru/legal/practicum_termsofuse"
	let didTapBuyButton: () -> Void
	let isLoaded: Bool
	let currencyAtLeastOneSelected: Bool
	let paymentInProgress: Bool
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			VStack(alignment: .leading, spacing: 4) {
				Text(.makingPurchaseAgree)
					.font(.regular13)
					.foregroundStyle(.ypBlack)
				
				Group {
					if let url = URL(string: userAgreementURLString) {
						Link(
							.userAgreement,
							destination: url
						)
					} else {
						Text(.userAgreement)
							.foregroundStyle(.ypBlack)
					}
				}
				.font(.regular13)
			}
			
			Button(action: didTapBuyButton) {
				HStack {
					Spacer()
					if isLoaded && !paymentInProgress {
						Text(.pay)
							.font(.bold17)
							.foregroundStyle(.ypWhite)
					} else {
						ProgressView()
							.colorMultiply(.ypWhite)
							.progressViewStyle(.circular)
					}
					Spacer()
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 16)
						.fill(.ypBlack)
				)
				
			}
			.opacity(currencyAtLeastOneSelected ? 1 : 0.5)
			.disabled(!(isLoaded && currencyAtLeastOneSelected))
			.frame(maxWidth: .infinity)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(.ypLightGrey)
				.ignoresSafeArea(edges: .bottom)
				.shadow(
					color: .ypBlackUniversal.opacity(0.2),
					radius: 10
				)
		)
		.animation(Constants.defaultAnimation, value: isLoaded)
		.animation(Constants.defaultAnimation, value: paymentInProgress)
	}
}

#if DEBUG
#Preview {
	PaymentMethodChooseBottomBar(
		didTapBuyButton: {},
		isLoaded: true,
		currencyAtLeastOneSelected: false,
		paymentInProgress: true
	)
}
#endif
