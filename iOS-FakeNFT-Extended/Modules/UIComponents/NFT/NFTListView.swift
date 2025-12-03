//
//  NFTListView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTListView: View {
	var body: some View {
		ScrollView(.vertical) {
			LazyVStack(spacing: 24) {
				NFTHorizontalCell()
				NFTHorizontalCell()
				NFTHorizontalCell()
				NFTHorizontalCell()
				NFTHorizontalCell()
			}
		}
		.padding(.horizontal, 16)
	}
}

#Preview {
	ZStack {
		Color.ypWhite
			.ignoresSafeArea()
		NFTListView()
	}
}
