//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTCollectionView: View {
    
    @StateObject private var asyncNFTs: AsyncNFTs
    private let nftsIDs: [String]
    private let errorIsPresented: Bool
    
    private let columns = [
        GridItem(.flexible(), spacing: 9, alignment: .top),
        GridItem(.flexible(), spacing: 9, alignment: .top),
        GridItem(.flexible(), spacing: 9, alignment: .top)
    ]
    
    init(
        nftsIDs: [String],
        nftService: NFTServiceProtocol,
        errorIsPresented: Bool
    ) {
        self.nftsIDs = nftsIDs
        self.errorIsPresented = errorIsPresented
        
        _asyncNFTs = .init(
            wrappedValue: .init(nftService: nftService)
        )
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 28
            ) {
                ForEach(
                    Array(asyncNFTs.visibleNFTs.enumerated()),
                    id: \.offset
                ) { index, model in
                    NFTVerticalCell(
                        model: model,
                        likeAction: {
                            asyncNFTs.didTapLikeButton(for: model)
                        },
                        cartAction: {
                            asyncNFTs.didTapCartButton(for: model)
                        }
                    )
                    .transition(.scale)
                    .transition(.blurReplace)
                }
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.25)
                        .blur(radius: phase.isIdentity ? 0 : 5, opaque: false)
                }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: asyncNFTs.visibleNFTs)
        .padding(.horizontal, 16)
        .scrollIndicators(.hidden)
        .task {
            await asyncNFTs.fetchNFTs(using: Set(nftsIDs))
        }
        .onDisappear(perform: asyncNFTs.viewDidDissappear)
        .applyRepeatableAlert(
            isPresented: .constant(errorIsPresented),
            message: "Не удалось получить данные", // TODO: move to constants
            didTapRepeat: {
                Task {
                    await asyncNFTs.loadFailedNFTs()
                }
            }
        )
    }
}
