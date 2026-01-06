//
//  MyNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import SwiftUI

struct MyNFTView: View {
    @State private var viewModel: MyNFTViewModel
    
    private let sortPlacement: BaseConfirmationDialogTriggerPlacement = .toolbar
    private static let myNFTSortOptionKey: String = "myNFTSortOptionKey"
    
    @AppStorage(myNFTSortOptionKey) private var sortOption: ProfileSortActionsViewModifier.SortOption = .name
    
    init(appContainer: AppContainer) {
        _viewModel = State(initialValue: MyNFTViewModel(appContainer: appContainer))
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            if viewModel.items.isEmpty {
                if viewModel.isLoading {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<6, id: \.self) { _ in
                                MyNFTShimmerRow()
                            }
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("У Вас ещё нет NFT")
                            .font(.bold17)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.items, id: \.id) { nft in
                            myRow(for: nft)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.items.isEmpty ? "" : "Мои NFT")
        .toolbar {
            if !viewModel.items.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Color.clear
                        .modifier(
                            ProfileSortActionsViewModifier(
                                activeSortOption: $sortOption,
                                placement: sortPlacement,
                                didTapCost: { sortOption = .cost },
                                didTapRate: { sortOption = .rate },
                                didTapName: { sortOption = .name }
                            )
                        )
                }
            }
        }
        .onAppear() {
            viewModel.setSortOption(sortOption)
        }
        .onChange(of: sortOption) {
            viewModel.setSortOption(sortOption)
        }
        .task {
            await viewModel.loadPurchasedNFTs()
        }
    }
    
    @ViewBuilder
    private func myRow(for nft: NFTModel) -> some View {
        VStack(spacing: 0) {
            NFTMyCellView(
                model: nft,
                likeAction: {}
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 140)
        }
        .background(Color.ypWhite)
    }
    
    private struct MyNFTShimmerRow: View {
        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 16) {

                    // Image placeholder (approx)
                    LoadingShimmerPlaceholderView()
                        .frame(width: 108, height: 108)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 10) {

                        // Title line
                        LoadingShimmerPlaceholderView()
                            .frame(width: 170, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                        // Subtitle line (author)
                        LoadingShimmerPlaceholderView()
                            .frame(width: 120, height: 12)
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                        Spacer(minLength: 0)

                        HStack {
                            // Stars / rating placeholder
                            LoadingShimmerPlaceholderView()
                                .frame(width: 90, height: 12)
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            Spacer()

                            // Price placeholder
                            LoadingShimmerPlaceholderView()
                                .frame(width: 70, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(16)
                .frame(height: 140)

                // Divider like your cell bottom border
                Rectangle()
                    .fill(Color.ypBlackUniversal.opacity(0.08))
                    .frame(height: 1)
            }
            .background(Color.ypWhite)
        }
    }
}
