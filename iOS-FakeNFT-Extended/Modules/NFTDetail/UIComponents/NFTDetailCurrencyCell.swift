//
//  NFTDetailCurrencyCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

struct NFTDetailCurrencyCell: View {
	let model: CurrencyContainer?
	let cost: Float
	private let imageSize: CGFloat = 32
	private let currencyPair_ETH_UDS_ratio: Float = 2957.66
	
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
				.foregroundStyle(.ypBlack)
				.applySkeleton(model)
			
			Text("$\(costLabel)")
				.font(.regular15)
				.foregroundStyle(.ypBlack)
				.applySkeleton(model)
		}
	}
	
	private var image: some View {
		Color.ypBackgroundUniversal
			.overlay {
				AsyncImage(
					url: URL(string: model?.currency.image ?? ""),
					transaction: .init(animation: .easeInOut(duration: 0.15))
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
