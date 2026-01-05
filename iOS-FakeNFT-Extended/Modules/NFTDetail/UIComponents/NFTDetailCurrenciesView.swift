//
//  NFTDetailCurrenciesView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

struct NFTDetailCurrenciesView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.currencies.elementsEqual(rhs.currencies, by: { $0.value == $1.value })
	}
	
	let currencies: [Dictionary<String, CurrencyContainer?>.Element]
	let cost: Float
	
	var body: some View {
		LazyVStack(spacing: 32) {
			if currencies.isEmpty {
				LoadingView(loadingState: .fetching)
					.padding(.vertical)
					.transition(.scale.combined(with: .opacity))
			}
			
			ForEach(currencies, id: \.key) { element in
				NFTDetailCurrencyCell(model: element.value, cost: cost)
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
				"0" : .init(currency: .mock, id: "0"),
				"1" : .init(currency: .mock, id: "1"),
				"2" : .init(currency: .mock, id: "2"),
				"3" : .init(currency: .mock, id: "3"),
				"4" : nil,
				"5" : .init(currency: .mock, id: "5"),
				"6" : .init(currency: .mock, id: "6"),
			].sorted { $0.key < $1.key },
			cost: 41.78
		)
	}
}
#endif
