//
//  NFTDetailCurrenciesView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

struct NFTDetailCurrenciesView: View {
	let currencies: [CurrencyContainer?]
	let cost: Float
	
	var body: some View {
		LazyVStack(spacing: 32) {
			if currencies.isEmpty {
				LoadingView(loadingState: .fetching)
					.padding(.vertical)
					.transition(.scale.combined(with: .opacity))
			}
			
			ForEach(
				Array(currencies.enumerated()),
				id: \.offset
			) { _, model in
				NFTDetailCurrencyCell(model: model, cost: cost)
					.listRowBackground(Color.clear)
					.listRowInsets(.init())
					.listRowSeparator(.hidden)
			}
		}
		.padding()
		.background(.ypLightGrey)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.padding(.horizontal)
		.shadow(color: .ypBlackUniversal.opacity(0.3), radius: 10)
		.animation(Constants.defaultAnimation, value: currencies)
	}
}

#if DEBUG
#Preview {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		NFTDetailCurrenciesView(
			currencies: [
				.init(currency: .mock, id: "0"),
				.init(currency: .mock, id: "1"),
				.init(currency: .mock, id: "2"),
				.init(currency: .mock, id: "3"),
				nil,
				.init(currency: .mock, id: "5"),
				.init(currency: .mock, id: "6"),
			],
			cost: 41.78
		)
	}
}
#endif
