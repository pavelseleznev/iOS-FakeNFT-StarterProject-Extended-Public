//
//  FavoriteNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/20/25.
//

import SwiftUI

struct FavoriteNFTView: View {
    
    @State private var viewModel: FavoriteNFTViewModel
    
    init(appContainer: AppContainer) {
        _viewModel = State(initialValue: FavoriteNFTViewModel(appContainer: appContainer))
    }
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            if viewModel.items.isEmpty {
                if viewModel.isLoading {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0..<8, id: \.self) { _ in
                                FavoriteNFTShimmerCell()
                            }
                        }
                        .padding([.horizontal, .top], 16)
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("У Вас ещё нет избранных NFT")
                            .font(.bold17)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(
                        columns: columns,
                        spacing: 20
                    ) {
                        ForEach(viewModel.items, id: \.id) { nft in
                            NFTCompactCellView(
                                model: nft,
                                isFavourited: false,
                                likeAction: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        // the VM will remove immediately when the task starts
                                        // so the UI animates away
                                    }
                                    Task(priority: .userInitiated) {
                                        await viewModel.removeFromFavorites(id: nft.id)
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
        .alert("Ошибка", isPresented: $viewModel.loadErrorPresented) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(viewModel.loadErrorMessage)
        }
        .task(priority: .userInitiated) {
            await viewModel.loadFavorites()
        }
    }
    
    private struct FavoriteNFTShimmerCell: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // square image placeholder
                LoadingShimmerPlaceholderView()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // title
                LoadingShimmerPlaceholderView()
                    .frame(height: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // price line
                LoadingShimmerPlaceholderView()
                    .frame(width: 80, height: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
