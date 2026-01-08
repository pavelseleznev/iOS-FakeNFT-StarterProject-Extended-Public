//
//  NFTNameRateAuthorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

fileprivate let placeholder = "Jhon Doe Jhon Doe Jhon Doe Jhon Doe"

struct NFTNameRateAuthorView: View {
	let model: NFTResponse?
	let layout: NFTCellLayout
	
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(model?.name ?? placeholder)
				.foregroundStyle(.ypBlack)
				.font(.regular15)
				.bold()
				.lineLimit(Constants.nftNameLineLimit)
				.applySkeleton(model)
			
			RatingPreview(rating: model?.rating)
			
			if case .my = layout {
				Text("от " + (model?.authorName ?? placeholder)) // TODO: Localize
					.foregroundStyle(.ypBlack)
					.font(.regular13)
					.lineLimit(Constants.nftNameLineLimit)
					.applySkeleton(model)
			}
		}
		.animation(Constants.defaultAnimation, value: model?.id)
	}
}
