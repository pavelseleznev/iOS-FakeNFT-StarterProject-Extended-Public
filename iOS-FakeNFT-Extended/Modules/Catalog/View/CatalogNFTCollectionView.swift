//
//  CatalogNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 23.12.2025.
//

import SwiftUI

struct CatalogNFTCollectionView: View {
    @State private var viewModel: CatalogNFTCollectionViewModel
    
    init(
        api: ObservedNetworkClient,
        push: @escaping (Page) -> Void
    ) {
        _viewModel = .init(
            initialValue: .init(
                api: api,
                push: push
            )
        )
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite
            
            VStack(spacing: .zero) {
                Image(.coverCollectionBig)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 310)
                    .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12))
                
                VStack(spacing: .zero) {
                    Text("Peach")
                        .foregroundStyle(.ypBlack)
                        .font(.bold22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Автор коллекции:")
                            .foregroundStyle(.ypBlack)
                            .font(.regular13)
                        
                        Button(action: {}) {
                            Text("John Doe")
                                .foregroundStyle(.ypBlueUniversal)
                                .font(.regular15)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.")
                        .foregroundStyle(.ypBlack)
                        .font(.regular13)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                NFTCollectionView(
                    nfts: viewModel.nfts,
                    likeActionOn: viewModel.didTapLikeButton,
                    cartActionOn: viewModel.didTapCartButton
                )
                .safeAreaPadding(.bottom)
                .padding(.bottom, 20)
                .padding(.top, 24)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    @Previewable let obsAPI: ObservedNetworkClient = {
        let api = DefaultNetworkClient()
        return .init(api: api)
    }()
    
    CatalogNFTCollectionView(
        api: .mock,
        push: { _ in }
    )
}
