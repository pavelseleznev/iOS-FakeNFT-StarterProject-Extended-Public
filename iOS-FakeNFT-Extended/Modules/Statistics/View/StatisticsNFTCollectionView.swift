//
//  StatisticsNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

struct StatisticsNFTCollectionView: View {
	private let nftsIDs: [String]
	private let nftService: NFTServiceProtocol
	private let loadingState: LoadingState
	private let didTapDetail: (NFTModelContainer) -> Void
	
	init(
		nftsIDs: [String],
		loadingState: LoadingState,
		nftService: NFTServiceProtocol,
		didTapDetail: @escaping (NFTModelContainer) -> Void
	) {
		self.nftsIDs = nftsIDs
		self.loadingState = loadingState
		self.nftService = nftService
		self.didTapDetail = didTapDetail
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			NFTCollectionView(
				nftsIDs: nftsIDs,
				nftService: nftService,
				didTapDetail: didTapDetail
			)
			.safeAreaPadding(.top)
		}
		.toolbar {
			ToolbarItem(placement: .title) {
				Text(.nftCollection)
					.foregroundStyle(.ypBlack)
					.font(.bold17)
			}
			ToolbarItem(placement: .destructiveAction) {
				ProgressView()
					.progressViewStyle(.circular)
					.opacity(loadingState == .fetching ? 1 : 0)
			}
		}
	}
}

#if DEBUG
#Preview {
	StatisticsNFTCollectionView(
		nftsIDs: [
			"d6a02bd1-1255-46cd-815b-656174c1d9c0",
			"f380f245-0264-4b42-8e7e-c4486e237504",
			"c14cf3bc-7470-4eec-8a42-5eaa65f4053c"
		],
		loadingState: .idle,
		nftService: NFTService(
			api: .mock,
			storage: NFTStorage()
		),
		didTapDetail: {_ in}
	)
}
#endif
