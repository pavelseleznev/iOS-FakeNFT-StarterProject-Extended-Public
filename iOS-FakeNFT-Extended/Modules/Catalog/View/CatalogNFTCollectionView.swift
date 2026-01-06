//
//  CatalogNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 23.12.2025.
//

import SwiftUI

struct CatalogNFTCollectionView: View {
    private let catalog: NFTCollectionItemResponse
    private let nftService: NFTServiceProtocol
    private let loadingState: LoadingState
    
    @State private var viewModel: CatalogNFTCollectionViewModel
    
    init(
        api: ObservedNetworkClient,
        push: @escaping (Page) -> Void,
        catalog: NFTCollectionItemResponse,
        loadingState: LoadingState,
        nftService: NFTServiceProtocol
    ) {
        self.catalog = catalog
        self.loadingState = loadingState
        self.nftService = nftService
        
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
                AsyncImage(url: catalog.coverImageURL) { image in
                    image
                        .resizable()
                } placeholder: {
                    Color.ypBackgroundUniversal
                        .overlay {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                }
                .scaledToFill()
                .frame(height: 310)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12))
                
                VStack(spacing: .zero) {
                    Text(catalog.name)
                        .foregroundStyle(.ypBlack)
                        .font(.bold22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Автор коллекции:")
                            .foregroundStyle(.ypBlack)
                            .font(.regular13)
                        
                        Button(action: viewModel.didTapCollectionAuthor) {
                            Text(catalog.author)
                                .foregroundStyle(.ypBlueUniversal)
                                .font(.regular15)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(catalog.description)
                        .foregroundStyle(.ypBlack)
                        .font(.regular13)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                NFTCollectionView(
                    nftsIDs: catalog.nftsIDs,
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
    @Previewable let obsAPI: ObservedNetworkClient = {
        let api = DefaultNetworkClient()
        return .init(api: api)
    }()
    
    CatalogNFTCollectionView(
        api: .mock,
        push: { _ in },
        catalog: .mock1,
        loadingState: .idle,
        nftService: NFTService(
            api: .mock,
            storage: NFTStorage()
        )
    )
}
