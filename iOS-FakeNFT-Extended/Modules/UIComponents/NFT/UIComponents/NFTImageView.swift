//
//  NFTImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTImageView: View {
    
    let model: NFTModel
    let layout: NFTCellLayout
    let likeAction: () -> Void
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                placeholder
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.ypWhiteUniversal)
                    }
                
            case .success(let image):
                image
                    .resizable()
            case .failure:
                placeholder
                    .overlay {
                        Image(systemName: "questionmark")
                            .font(.bold22)
                            .foregroundStyle(.ypWhiteUniversal)
                    }
                
            @unknown default:
                placeholder
            }
        }
        .scaledToFit()
        .overlay(alignment: .topTrailing) {
            Button(action: likeAction) {
                Image.heartFill
                    .padding(.top, 10)
                    .padding(.trailing, 8)
                    .foregroundStyle(
                        model.isFavorite ? .ypRedUniversal : .ypWhiteUniversal
                    )
                    .shadow(color: .ypBlackUniversal.opacity(0.6), radius: 10)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
    }
    
    private var imageURL: URL? {
        let trimmed = model.imageURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              ["http", "https"].contains(url.scheme?.lowercased() ?? "")
        else { return nil }
        return url
    }
    
    private var placeholder: some View {
        Color.ypBlackUniversal
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
