//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTCollectionView: View {
	
	private let columns = [
		GridItem(.flexible(), spacing: 8),
		GridItem(.flexible(), spacing: 8),
		GridItem(.flexible(), spacing: 8)
	]
	
	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(
				columns: columns,
				alignment: .center,
				spacing: 28,
				pinnedViews: .sectionFooters
			) {
				NFTVerticalCell()
				NFTVerticalCell()
				NFTVerticalCell()
				NFTVerticalCell()
				NFTVerticalCell()
				NFTVerticalCell()
			}
		}
		.padding(.horizontal, 16)
	}
}

#Preview {
	ZStack {
		Color.ypWhite
			.ignoresSafeArea()
		NFTCollectionView()
	}
}
