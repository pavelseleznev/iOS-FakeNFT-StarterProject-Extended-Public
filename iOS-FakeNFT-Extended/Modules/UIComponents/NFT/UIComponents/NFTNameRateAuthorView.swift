//
//  NFTNameRateAuthorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTNameRateAuthorView: View {
	
	let model: NFTModel
	let layout: NFTCellLayout
	
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(model.name)
				.foregroundStyle(.ypBlack)
				.font(.bold17)
			
			RatingPreview(rating: model.rate)
			
			if case .my = layout {
				Text("от: " + model.author)
					.foregroundStyle(.ypBlack)
					.font(.regular13)
			}
		}
	}
}

