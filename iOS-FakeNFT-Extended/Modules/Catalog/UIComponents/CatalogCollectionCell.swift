//
//  NFTCollectionCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 22.12.2025.
//

import SwiftUI

struct CatalogCollectionCell: View {
    let model: NFTCollectionItemResponse
	let isMock: Bool
    
    var body: some View {
        VStack(spacing: 4) {
			AsyncImageCached(urlString: model.coverImageURLString) { phase in
				Color.ypBackgroundUniversal
					.overlay {
						switch phase {
						case .empty, .error:
							ProgressView()
								.progressViewStyle(.circular)
						case .loaded(let uIImage):
							Image(uiImage: uIImage)
								.resizable()
								.scaledToFill()
						}
					}
			}
            .frame(height: 140)
			.applySkeleton(isMock ? nil : 0)
            .clipShape(RoundedRectangle(cornerRadius: 28))
			.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 10)
            
            Text("\(model.name) (\(Set(model.nftsIDs).count))")
                .foregroundStyle(.ypBlack)
                .font(.bold17)
                .frame(maxWidth: .infinity, alignment: .leading)
				.applySkeleton(isMock ? nil : 0)
				.clipShape(.capsule)
				.padding(.horizontal)
            
            Spacer()
        }
		.animation(nil, value: isMock)
        .frame(height: 179)
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
	@Previewable @State var isMock = true
	
	Color.ypWhite.ignoresSafeArea()
		.overlay {
			CatalogCollectionCell(model: .mock1, isMock: false)
		}
}
#endif
