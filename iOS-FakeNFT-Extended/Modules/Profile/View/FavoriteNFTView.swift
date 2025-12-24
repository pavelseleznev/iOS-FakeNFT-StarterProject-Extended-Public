//
//  FavoriteNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/20/25.
//

import SwiftUI

struct FavoriteNFTView: View {
    
    @Bindable var favoriteStore: FavoriteNFTViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            if favoriteStore.items.isEmpty {
                VStack {
                    Spacer()
                    Text("У Вас ещё нет избранных NFT")
                        .font(.bold17)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(
                        columns: columns,
                        spacing: 20
                    ) {
                        ForEach(favoriteStore.items, id: \.id) { nft in
                            NFTCompactCellView(
                                model: nft,
                                likeAction: {
                                    withAnimation {
                                        favoriteStore.removeFavorite(id: nft.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding([.horizontal, .top], 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if !favoriteStore.items.isEmpty {
                    Text("Избранные NFT")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview("With NFTs") {
    NavigationStack {
        FavoriteNFTView(favoriteStore: FavoriteNFTViewModel(items: NFTModel.favoriteMocks))
    }
}

#Preview("Empty Preview") {
    NavigationStack {
        FavoriteNFTView(favoriteStore: FavoriteNFTViewModel(items: []))
    }
}
