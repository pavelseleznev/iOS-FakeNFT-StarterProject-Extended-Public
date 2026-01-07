//
//  NFTNameRateAuthorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTNameRateAuthorView: View {
    
    let model: NFTResponse
    let layout: NFTCellLayout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.name)
                .foregroundStyle(.ypBlack)
                .font(.bold17)
                .lineLimit(Constants.nftNameLineLimit)
            
            RatingPreview(rating: model.rating)
            
            if case .my = layout {
                Text("от " + model.authorName)
                    .foregroundStyle(.ypBlack)
                    .font(.regular13)
                    .lineLimit(Constants.authorNameLineLimit)
            }
        }
    }
}
