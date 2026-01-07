//
//  PaymentMethodChooseCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

fileprivate let imageSize: CGFloat = 36

struct PaymentMethodChooseCell: View {
	let currency: CurrencyResponse
	let selected: Bool
	
	var body: some View {
		HStack {
			ImageView(urlString: currency.image)

			VStack(alignment: .leading) {
				Text(currency.title)
					.foregroundStyle(.ypBlack)
				
				Text(currency.id)
					.foregroundStyle(.ypGreenUniversal)
			}
			.font(.regular13)
			.bold()
			
			Spacer()
		}
		.padding(.vertical, 10)
		.padding(.horizontal, 12)
		.background(
			Capsule()
				.fill(
					.ypLightGrey
						.shadow(
							.inner(
								color: .ypBlack.opacity(selected ? 0.2 : 0),
								radius: 10
							)
						)
				)
				.strokeBorder(
					Color.ypBlack,
					lineWidth: selected ? 1 : 0
				)
		)
		.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 8)
	}
}

// MARK: - Helper
fileprivate struct ImageView: View {
	let urlString: String
	
	var body: some View {
		AsyncImageCached(urlString: urlString) { phase in
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


// MARK: - Preview
#if DEBUG
#Preview {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		PaymentMethodChooseCell(currency: .mock, selected: true)
			.frame(width: 180)
	}
}
#endif
