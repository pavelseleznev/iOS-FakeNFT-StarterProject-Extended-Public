//
//  NFTDetailCurrenciesView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

struct NFTDetailCurrenciesView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.currencies.map(\.id) == rhs.currencies.map(\.id)
	}
	
	let currencies: [CurrencyContainer]
	let cost: Float
	
	var body: some View {
		LazyVStack(spacing: 32) {
			if currencies.isEmpty {
				LoadingView(loadingState: .fetching)
					.padding(.vertical)
					.transition(.scale.combined(with: .opacity))
			}
			
			ForEach(currencies, id: \.id) { container in
				NFTDetailCurrencyCell(model: container, cost: cost)
					.id(container.id)
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
				.init(currency: .mock, id: "4"),
				.init(currency: .mock, id: "5"),
				.init(currency: .mock, id: "6"),
			],
			cost: 41.78
		)
	}
}
#endif
