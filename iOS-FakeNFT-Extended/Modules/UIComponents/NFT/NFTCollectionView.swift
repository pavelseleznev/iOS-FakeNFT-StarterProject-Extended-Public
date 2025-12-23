//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTCollectionView: View {
	
	@StateObject private var asyncNFTs: AsyncNFTs
	private let nftsIDs: [String]
	private let errorIsPresented: Bool
	
	init(
		nftsIDs: [String],
		nftService: NFTServiceProtocol,
		errorIsPresented: Bool
	) {
		self.nftsIDs = nftsIDs
		self.errorIsPresented = errorIsPresented
		
		_asyncNFTs = .init(
			wrappedValue: .init(nftService: nftService)
		)
	}
	
	private let columns = [
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top)
	]
	
	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(
				columns: columns,
				alignment: .center,
				spacing: 28
			) {
				ForEach(
					Array(asyncNFTs.visibleNFTs.enumerated()),
					id: \.offset
				) { index, model in
					NFTVerticalCell(
						model: model,
						likeAction: {
							asyncNFTs.didTapLikeButton(for: model)
						},
						cartAction: {
							asyncNFTs.didTapCartButton(for: model)
						}
					)
					.transition(.scale)
					.transition(.blurReplace)
				}
				.scrollTransition { content, phase in
					content
						.opacity(phase.isIdentity ? 1 : 0.25)
						.blur(radius: phase.isIdentity ? 0 : 5, opaque: false)
				}
			}
		}
		.animation(.easeInOut(duration: 0.15), value: asyncNFTs.visibleNFTs)
		.padding(.horizontal, 16)
		.scrollIndicators(.hidden)
		.task {
			await asyncNFTs.fetchNFTs(using: Set(nftsIDs))
		}
		.onDisappear(perform: asyncNFTs.viewDidDissappear)
		.applyRepeatableAlert(
			isPresneted: .constant(errorIsPresented),
			message: "Не удалось получить данные", // TODO: move to constants
			didTapRepeat: {
				Task {
					await asyncNFTs.loadFailedNFTs()
				}
			}
		)
	}
}

#if DEBUG
#Preview {
	@Previewable let service = NFTService(
		api: .init(api: DefaultNetworkClient()),
			  storage: NFTStorage()
	  )
	
	ZStack {
		Color.ypWhite
			.ignoresSafeArea()
		NFTCollectionView(
			nftsIDs: [
				"1fda6f0c-a615-4a1a-aa9c-a1cbd7cc76ae",
				"77c9aa30-f07a-4bed-886b-dd41051fade2",
				"b3907b86-37c4-4e15-95bc-7f8147a9a660",
				"f380f245-0264-4b42-8e7e-c4486e237504",
				"9810d484-c3fc-49e8-bc73-f5e602c36b40",
				"c14cf3bc-7470-4eec-8a42-5eaa65f4053c",
				"b2f44171-7dcd-46d7-a6d3-e2109aacf520",
				"e33e18d5-4fc2-466d-b651-028f78d771b8",
				"db196ee3-07ef-44e7-8ff5-16548fc6f434",
				"e8c1f0b6-5caf-4f65-8e5b-12f4bcb29efb",
				"739e293c-1067-43e5-8f1d-4377e744ddde",
				"d6a02bd1-1255-46cd-815b-656174c1d9c0",
				"de7c0518-6379-443b-a4be-81f5a7655f48",
				"82570704-14ac-4679-9436-050f4a32a8a0"
			],
			nftService: service,
			errorIsPresented: false
		)
	}
}
#endif
