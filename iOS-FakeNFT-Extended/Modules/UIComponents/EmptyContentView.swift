//
//  EmptyContentType.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

enum EmptyContentType {
	case nfts, cart, currencies
	
	var title: LocalizedStringResource {
		switch self {
		case .nfts:
			.authorHasNoNFTs
		case .cart:
			.shoppingCartIsEmpty
		case .currencies:
			.noCurrenciesAvailable
		}
	}
}

struct EmptyContentView: View {
	let type: EmptyContentType
	var body: some View {
		VStack(alignment: .center) {
			Text(type.title)
				.font(.bold17)
				.foregroundStyle(.ypBlack)
			
			HStack(spacing: 8) {
				ProgressView()
					.progressViewStyle(.circular)
				
				textView
					.opacity(0)
					.overlay {
						LoadingShimmerPlaceholderView()
							.mask(textView)
					}
			}
		}
		.transition(.scale.combined(with: .opacity))
	}
	
	private var textView: some View {
		Group {
			Text(.updating) + Text("...")
		}
		.font(.regular17)
		.foregroundStyle(.ypGrayUniversal)
	}
}
