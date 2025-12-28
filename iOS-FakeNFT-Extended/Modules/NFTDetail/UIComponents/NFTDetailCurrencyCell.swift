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
	let model: CurrencyContainer?
	let cost: Float
	
	var body: some View {
		HStack(spacing: 10) {
			image
			nameAndDollarCost
			Spacer()
			cryptoCost
		}
	}
	
	private var cryptoCostLabel: String {
		String(format: "%.1f", cost).replacingOccurrences(of: ".", with: ",")
	}
	
	private var costLabel: String {
		String(format: "%.2f", cost * currencyPair_ETH_UDS_ratio)
	}
	
	private var cryptoCost: some View {
		Text("\(cryptoCostLabel) (\(model?.currency.id ?? "BTC"))")
			.font(.regular13)
			.foregroundStyle(.ypGreenUniversal)
			.applySkeleton(model)
	}
	
	private var nameAndDollarCost: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("\(model?.currency.title ?? "Bitcoin") (\(model?.currency.id ?? "BTC"))")
				.font(.regular13)
				.applySkeleton(model)
			
			Text("$\(costLabel)")
				.font(.regular15)
				.applySkeleton(model)
		}
		.foregroundStyle(.ypBlack)
	}
	
	private var image: some View {
		Color.ypBackgroundUniversal
			.overlay {
				AsyncImage(
					url: URL(string: model?.currency.image ?? ""),
					transaction: .init(animation: Constants.defaultAnimation)
				) { phase in
					switch phase {
					case .empty:
						ProgressView()
							.progressViewStyle(.circular)
					case .success(let image):
						image
							.resizable()
							.scaledToFit()
					default:
						Text("?")
							.font(.bold17)
							.foregroundStyle(.ypBlack)
					}
				}
			}
			.frame(width: imageSize, height: imageSize)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.applySkeleton(model)
	}
}
