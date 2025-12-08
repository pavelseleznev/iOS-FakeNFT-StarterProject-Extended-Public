//
//  StatisticsNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

struct StatisticsNFTCollectionView: View {
	@State private var viewModel: StatisticsNFTCollectionViewModel
	
	init(
		nfts: [NFTModel],
		api: ObservedNetworkClient,
	) {
		_viewModel = .init(
			initialValue: .init(nfts: nfts, api: api)
		)
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			NFTCollectionView(
				nfts: viewModel.nfts,
				likeActionOn: viewModel.didTapLikeButton,
				cartActionOn: viewModel.didTapCartButton
			)
			.safeAreaPadding(.top)
		}
		.toolbar {
			ToolbarItem(placement: .title) {
				Text("Коллекция NFT")
					.foregroundStyle(.ypBlack)
					.font(.bold17)
			}
		}
	}
}

#if DEBUG
#Preview {
	StatisticsNFTCollectionView(
		nfts: [.mock, .mock, .badImageURLMock, .badImageURLMock, .mock, .mock],
		api: .mock
	)
}
#endif
