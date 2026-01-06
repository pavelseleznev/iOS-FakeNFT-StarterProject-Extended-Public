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
    @State private var reloadID = UUID()
    @State private var didRetry = false
    
    var body: some View {
        AsyncImage(
            url: URL(string: model.imageURLString.trimmingCharacters(in: .whitespacesAndNewlines))
        ) { phase in
            switch phase {
            case .empty:
                placeholder
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.ypWhiteUniversal)
                    }
                
            case .success(let image):
                image.resizable()
            case .failure:
                placeholder
                    .task {
                        guard !didRetry else { return }
                            didRetry = true
                            
                            try? await Task.sleep(for: .milliseconds(200))
                            reloadID = UUID()
                        }
            @unknown default:
                placeholder
            }
        }
        .id(reloadID)
        .scaledToFit()
        .overlay(alignment: .topTrailing) {
            Button(action: likeAction) {
                Image.heartFill
                    .padding(.top, 10)
                    .padding(.trailing, 8)
                    .foregroundStyle(model.isFavorite ? .ypRedUniversal : .ypWhiteUniversal)
                    .shadow(color: .ypBlackUniversal.opacity(0.6), radius: 10)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var placeholder: some View {
        Color.ypBlackUniversal
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
