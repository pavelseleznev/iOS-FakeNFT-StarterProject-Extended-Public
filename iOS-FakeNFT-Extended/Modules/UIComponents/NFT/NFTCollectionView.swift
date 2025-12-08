//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTCollectionView: View {
	
	let nfts: [NFTModel]
	let likeActionOn: (NFTModel) -> Void
	let cartActionOn: (NFTModel) -> Void
	
	private let columns = [
		GridItem(.flexible(), spacing: 9),
		GridItem(.flexible(), spacing: 9),
		GridItem(.flexible(), spacing: 9)
	]
	
	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(
				columns: columns,
				alignment: .center,
				spacing: 28
			) {
				ForEach(nfts) { nft in
					NFTVerticalCell(
						model: nft,
						likeAction: { likeActionOn(nft) },
						cartAction: { cartActionOn(nft) }
					)
				}
			}
		}
		.padding(.horizontal, 16)
		.scrollIndicators(.hidden)
	}
}

#if DEBUG
#Preview {
	ZStack {
		Color.ypWhite
			.ignoresSafeArea()
		NFTCollectionView(
			nfts: [
				.mock,
				.mock,
				.mock,
				.mock,
				.badImageURLMock,
				.mock,
				.mock,
				.badImageURLMock,
				.mock,
				.badImageURLMock
			],
			likeActionOn: {_ in},
			cartActionOn: {_ in}
		)
	}
}
#endif
