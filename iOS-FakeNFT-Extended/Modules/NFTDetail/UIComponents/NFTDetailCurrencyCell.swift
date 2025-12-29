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
