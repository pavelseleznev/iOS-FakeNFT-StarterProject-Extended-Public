//
//  NFTCostView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTCostView: View {
	let model: NFTResponse?
	let layout: NFTCellLayout
	
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			if layout != .compact {
				Text(.cost)
					.foregroundStyle(.ypBlack)
					.font(.regular13)
			}
			
			Text(String(format: "%.2f", model?.price ?? 99.99) + " ETH")
				.foregroundStyle(.ypBlack)
				.font(.bold17)
				.applySkeleton(model)
		}
	}
}
