//
//  CatalogNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 23.12.2025.
//

import SwiftUI

struct CatalogNFTCollectionView: View {
    private let nftsIDs: [String]
    private let nftService: NFTServiceProtocol
    private let loadingState: LoadingState
    
    init(
        nftsIDs: [String],
        loadingState: LoadingState,
        nftService: NFTServiceProtocol
    ) {
        self.nftsIDs = nftsIDs
        self.loadingState = loadingState
        self.nftService = nftService
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
                    nftsIDs: nftsIDs,
                    nftService: nftService,
                    errorIsPresented: loadingState == .error
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
    CatalogNFTCollectionView(
        nftsIDs: [
            "d6a02bd1-1255-46cd-815b-656174c1d9c0",
            "f380f245-0264-4b42-8e7e-c4486e237504",
            "c14cf3bc-7470-4eec-8a42-5eaa65f4053c"
        ],
        loadingState: .idle,
        nftService: NFTService(
            api: .mock,
            storage: NFTStorage()
        )
    )
}
