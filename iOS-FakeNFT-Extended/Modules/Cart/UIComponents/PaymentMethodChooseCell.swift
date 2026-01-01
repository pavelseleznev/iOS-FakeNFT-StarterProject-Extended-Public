//
//  PaymentMethodChooseCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

fileprivate let imageSize: CGFloat = 36

struct PaymentMethodChooseCell: View {
	let currency: CurrencyResponse?
	let selected: Bool
	
	var body: some View {
		HStack {
			AsyncImageCached(urlString: currency?.image ?? "") { phase in
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
			.applySkeleton(currency)
			.clipShape(RoundedRectangle(cornerRadius: 6))

			VStack(alignment: .leading) {
				Text(currency?.title ?? "Bitcoin")
					.foregroundStyle(.ypBlack)
					.overlay {
						if currency == nil {
							LoadingShimmerPlaceholderView()
								.padding(.vertical, 1)
								.scaleEffect(x: 1.1)
						}
					}
				
				Text(currency?.id ?? "BTC")
					.foregroundStyle(.ypGreenUniversal)
					.overlay {
						if currency == nil {
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
	PaymentMethodChooseCell(currency: .mock, selected: true)
}
#endif
