//
//  StatisticsNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

struct StatisticsNFTCollectionView: View {
	private let authorID: String
	private let initialNFTsIDs: [String]
	private let loadAuthor: (String) async throws -> UserListItemResponse
	private let nftService: NFTServiceProtocol
	private let loadingState: LoadingState
	private let didTapDetail: (NFTModelContainer, [Dictionary<String, NFTModelContainer?>.Element]) -> Void
	
	init(
		initialNFTsIDs: [String],
		authorID: String,
		loadingState: LoadingState,
		nftService: NFTServiceProtocol,
		loadAuthor: @escaping (String) async throws -> UserListItemResponse,
		didTapDetail: @escaping (NFTModelContainer, [Dictionary<String, NFTModelContainer?>.Element]) -> Void
	) {
		self.authorID = authorID
		self.initialNFTsIDs = initialNFTsIDs
		self.loadingState = loadingState
		self.nftService = nftService
		self.loadAuthor = loadAuthor
		self.didTapDetail = didTapDetail
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			NFTCollectionView(
				initialNFTsIDs: initialNFTsIDs,
				authorID: authorID,
				nftService: nftService,
				loadAuthor: loadAuthor,
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
		initialNFTsIDs: [
			"d6a02bd1-1255-46cd-815b-656174c1d9c0",
			"f380f245-0264-4b42-8e7e-c4486e237504",
			"c14cf3bc-7470-4eec-8a42-5eaa65f4053c"
		],
		authorID: "ab33768d-02ac-4f45-9890-7acf503bde54",
		loadingState: .idle,
		nftService: NFTService.mock,
		loadAuthor: ObservedNetworkClient().getUser,
		didTapDetail: {_, _ in}
	)
}
#endif
