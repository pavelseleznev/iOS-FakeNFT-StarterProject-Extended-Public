//
//  MyNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import SwiftUI

struct MyNFTView: View {
    
    @Bindable var viewModel: MyNFTViewModel
    
    private let sortPlacement: BaseConfirmationDialogTriggerPlacement = .toolbar
    private static let myNFTSortOptionKey: String = "myNFTSortOptionKey"
    
    @AppStorage(myNFTSortOptionKey) private var sortOption: ProfileSortActionsViewModifier.SortOption = .name
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            if viewModel.items.isEmpty {
                VStack {
                    Spacer()
                    Text("У Вас ещё нет NFT")
                        .font(.bold17)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
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
}

#Preview("With NFTs") {
    NavigationStack {
        MyNFTView(
            viewModel: MyNFTViewModel(
                items: [.mock1, .mock2, .mock3]
            )
        )
    }
}

#Preview("Empty Preview") {
    NavigationStack {
        MyNFTView(viewModel: MyNFTViewModel(items: []))
    }
}
