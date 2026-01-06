//
//  NFTDetailCurrencyCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

fileprivate let imageSize: CGFloat = 32
fileprivate let currencyPair_ETH_UDS_ratio: Float = 2957.66

struct NFTDetailCurrencyCell: View {
	let model: CurrencyContainer
	let cost: Float
	
	var body: some View {
		HStack(spacing: 10) {
			ImageView(urlString: model.currency.image)
			
			nameAndDollarCost
			
			Spacer()
			
			cryptoCost
		}
	}
}

// MARK: - NFTDetailCurrencyCell Extenion
// --- subviews ---
private extension NFTDetailCurrencyCell {
	private var cryptoCost: some View {
		Text("\(cryptoCostLabel) (\(model.currency.id))")
			.font(.regular13)
			.foregroundStyle(.ypGreenUniversal)
	}
	
	private var nameAndDollarCost: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("\(model.currency.title) (\(model.currency.id))")
				.font(.regular13)
			
			Text("$\(costLabel)")
				.font(.regular15)
		}
		.foregroundStyle(.ypBlack)
	}
}

// --- getters ---
private extension NFTDetailCurrencyCell {
	private var cryptoCostLabel: String {
		getString(from: cost, format: "%.1f")
	}
	
	private var costLabel: String {
		getString(from: cost * currencyPair_ETH_UDS_ratio, format: "%.2f")
	}
	
	private func getString(from value: Float, format: String) -> String {
		let string = "\(value)"
		if let double = Double(string) {
			return String(format: "%.1f", double).replacingOccurrences(of: ".", with: ",")
		} else {
			return "0,0"
		}
	}
}

// MARK: - Helper
fileprivate struct ImageView: View {
	let urlString: String
	var body: some View {
		AsyncImageCached(
			urlString: urlString,
			placeholder: .vector
		) { phase in
			switch phase {
			case .empty:
				Color.ypLightGrey
					.overlay {
						ProgressView()
					}
			case .loaded(let image):
				Image(uiImage: image)
					.resizable()
			case .error:
				Color.ypLightGrey
					.overlay {
						Text("?")
							.font(.bold17)
							.foregroundStyle(.ypWhiteUniversal)
					}
			}
		}
		.frame(width: imageSize, height: imageSize)
		.clipShape(RoundedRectangle(cornerRadius: 6))
	}
}
