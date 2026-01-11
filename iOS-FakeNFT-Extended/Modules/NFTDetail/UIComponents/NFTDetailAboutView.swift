//
//  NFTDetailAboutView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct NFTDetailAboutView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.nft.id == rhs.nft.id
	}
	
	let nft: NFTResponse
	
	var body: some View {
		HStack(spacing: 8) {
			Text(nft.name)
				.font(.bold22)
				.textModifiers()
			
			RatingPreview(rating: nft.rating)
			
			Spacer()
			
			Text(nft.authorName)
				.font(.bold17)
				.textModifiers()
		}
		.padding(.horizontal)
	}
}

// MARK: - View helper
private extension View {
	func textModifiers() -> some View {
		self
			.foregroundStyle(.ypBlack)
			.lineLimit(Constants.nftNameLineLimit)
			.frame(maxWidth: 100)
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	NFTDetailAboutView(nft: .mock)
}
#endif
