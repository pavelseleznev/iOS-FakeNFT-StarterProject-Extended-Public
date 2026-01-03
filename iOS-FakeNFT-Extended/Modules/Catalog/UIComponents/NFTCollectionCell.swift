//
//  NFTCollectionCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 22.12.2025.
//

import SwiftUI

struct NFTCollectionCell: View {
    let model: NFTCollectionItemResponse
    
    var body: some View {
        VStack(spacing: .zero) {
            Group {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                } placeholder: {
                    Color.ypBackgroundUniversal
                        .overlay {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                }
            }
            .scaledToFill()
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("\(model.name) (\(model.nftsIDs.count))")
                .foregroundStyle(.ypBlack)
                .font(.bold17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            
            Spacer()
        }
        .frame(height: 179)
        .padding(.horizontal, 16)
    }
    
    private var imageURL: URL? {
        URL(string: model.coverImageURLString)
    }
}

#Preview {
    NFTCollectionCell(model: .mock1)
}
