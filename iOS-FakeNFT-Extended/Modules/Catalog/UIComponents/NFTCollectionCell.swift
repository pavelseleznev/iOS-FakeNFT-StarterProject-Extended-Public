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
            Image(.coverCollectionMedium)
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("Peach (11)")
                .foregroundStyle(.ypBlack)
                .font(.bold17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            
            Spacer()
        }
        .frame(height: 179)
        .padding(.horizontal, 16)
    }
}

#Preview {
    NFTCollectionCell(model: .mock)
}
