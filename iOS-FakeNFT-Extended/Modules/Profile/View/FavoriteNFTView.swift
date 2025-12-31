//
//  FavoriteNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/20/25.
//

import SwiftUI

struct FavoriteNFTView: View {
    
    @Bindable var viewModel: FavoriteNFTViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            if viewModel.items.isEmpty {
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
                        ForEach(viewModel.items, id: \.id) { nft in
                            NFTCompactCellView(
                                model: nft,
                                likeAction: {
                                    let oldItems = viewModel.items
                                    
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        _ = viewModel.removeLocal(id: nft.id)
                                    }
                                    
                                    Task(priority: .userInitiated) { @MainActor in
                                        do {
                                            try await viewModel.syncLikesToServer()
                                        } catch {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                viewModel.restore(oldItems)
                                            }
                                        }
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
                if !viewModel.items.isEmpty {
                    Text("Избранные NFT")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview("With NFTs") {
    NavigationStack {
        FavoriteNFTView(
            viewModel: FavoriteNFTViewModel(
                items: [.preview, .preview, .preview],
                service: PreviewProfileService()
            )
        )
    }
}

#Preview("Empty Preview") {
    NavigationStack {
        FavoriteNFTView(viewModel: FavoriteNFTViewModel(
            items: [],
            service: PreviewProfileService())
        )
    }
}
