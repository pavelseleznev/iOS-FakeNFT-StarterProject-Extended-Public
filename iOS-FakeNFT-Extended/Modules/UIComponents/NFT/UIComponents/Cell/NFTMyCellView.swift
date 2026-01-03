//
//  NFTHorizontalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTMyCellView: View {
    
    let model: NFTResponse
    let isFavourited: Bool
    let likeAction: () -> Void
    
    private let layout: NFTCellLayout = .my
    
    var body: some View {
        HStack(spacing: 20) {
            NFTImageView(
                model: model,
                isFavourited: isFavourited,
                layout: layout,
                likeAction: likeAction,
            )
            .frame(width: 108)
            
            HStack {
                NFTNameRateAuthorView(
                    model: model,
                    layout: layout
                )
                Spacer()
                NFTCostView(model: model, layout: layout)
            }
            .padding(.trailing, 30)
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var models: [NFTResponse] = [
        .mock,
        .mock,
        .badImageURLMock,
        .mock,
        .badImageURLMock
    ]
    
    ZStack {
        Color.ypWhite.ignoresSafeArea()
        
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(models) {
                    NFTMyCellView(
                        model: $0,
                        isFavourited: false,
                        likeAction: {}
                    )
                }
            }
        }
    }
}
#endif
