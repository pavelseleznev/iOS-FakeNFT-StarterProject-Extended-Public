//
//  PaymentMethodChooseCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct PaymentMethodChooseCell: View {
	let currnecy: CurrencyResponse?
	let selected: Bool
	
	var body: some View {
		HStack {
			AsyncImage(
				url: URL(string: currnecy?.image ?? ""),
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
					Image(.vector)
						.resizable()
						.scaledToFit()
				}
			}
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.frame(width: 36, height: 36)
			.overlay {
				if currnecy == nil {
					LoadingShimmerPlaceholderView()
				}
			}

			VStack(alignment: .leading) {
				Text(currnecy?.title ?? "Bitcoin")
					.foregroundStyle(.ypBlack)
					.overlay {
						if currnecy == nil {
							LoadingShimmerPlaceholderView()
								.padding(.vertical, 1)
								.scaleEffect(x: 1.1)
						}
					}
				
				Text(currnecy?.id ?? "BTC")
					.foregroundStyle(.ypGreenUniversal)
					.overlay {
						if currnecy == nil {
							LoadingShimmerPlaceholderView()
								.padding(.vertical, 1)
								.scaleEffect(x: 1.1)
						}
					}
			}
			.font(.regular13)
			
			Spacer()
		}
		.padding(.vertical, 5)
		.padding(.horizontal, 12)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(.ypLightGrey)
				.strokeBorder(
					Color.ypBlack,
					lineWidth: selected ? 1 : 0
				)
		)
	}
}

#if DEBUG
#Preview {
	PaymentMethodChooseCell(currnecy: .mock, selected: true)
}
#endif
