//
//  NFTImageView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI
import Kingfisher

struct NFTImageView: View {
	
	let model: NFTModel
	let layout: NFTCellLayout
	let likeAction: () -> Void
	
	var body: some View {
		Group {
            let trimmed = model.imageURLString.trimmingCharacters(in: .whitespacesAndNewlines)
            if let url = URL(string: trimmed),
               ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                KFImage(url)
                    .placeholder {
                        placeholder
                    }
                    .resizable()
                    .scaledToFit()
            } else  if !trimmed.isEmpty {
                Image(trimmed)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
            }
		}
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
    
    private var placeholder: some View {
        ZStack {
            Color.ypBackgroundUniversal
            Text("?")
                .font(.bold22)
                .foregroundStyle(.ypWhiteUniversal)
        }
    }
}
