//
//  MyNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import SwiftUI

struct MyNFTView: View {
    
    private let sortPlacement: BaseConfirmationDialogTriggerPlacement = .toolbar
    private static let myNFTSortOptionKey: String = "myNFTSortOptionKey"
    
    @AppStorage(myNFTSortOptionKey) private var sortOption: ProfileSortActionsViewModifier.SortOption = .name
    
    @State private var viewModel = MyNFTViewModel(items: [.mock1, .mock2, .mock3])
    
    init(viewModel: MyNFTViewModel = MyNFTViewModel(items: [.mock1, .mock2, .mock3])) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
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
                        ForEach(viewModel.items) { nft in
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
                                didTapCost: { viewModel.sort(by: .cost) },
                                didTapRate: { viewModel.sort(by: .rate) },
                                didTapName: { viewModel.sort(by: .name) }
                            )
                        )
                }
            }
        }
        .onAppear() {
            viewModel.sort(by: sortOption)
        }
        .onChange(of: sortOption) {
            viewModel.sort(by: sortOption)
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
        MyNFTView()
    }
}

#Preview("Empty Preview") {
    NavigationStack {
        MyNFTView(viewModel: MyNFTViewModel(items: []))
    }
}
