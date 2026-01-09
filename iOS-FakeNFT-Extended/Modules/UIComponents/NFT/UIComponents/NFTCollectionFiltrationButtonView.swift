//
//  NFTCollectionFiltrationButtonView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 30.12.2025.
//

import SwiftUI

struct NFTCollectionFiltrationButtonView: View {
	@EnvironmentObject private var asyncNFTs: NFTCollectionViewModel
	
	var body: some View {
		Circle()
			.fill(.bar)
			.frame(width: 60)
			.shadow(color: .ypBlack.opacity(0.2), radius: 5)
			.overlay {
				NFTCollectionToolbarView(
					activeTokens: $asyncNFTs.activeTokens,
					tokenAction: asyncNFTs.tokenAction,
					isActive: { asyncNFTs.activeTokens.contains($0) },
					atLeastOneSelected: !asyncNFTs.activeTokens.isEmpty,
				)
				.font(.bold32)
			}
			.padding([.trailing, .bottom])
			.transition(
				.asymmetric(
					insertion: .move(edge: .leading),
					removal: .move(edge: .trailing)
				)
			)
	}
}
