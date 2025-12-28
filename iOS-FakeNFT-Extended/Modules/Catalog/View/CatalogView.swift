//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct CatalogView: View {
    @State private var viewModel: CatalogViewModel
    
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
            Color.ypWhite.ignoresSafeArea()
            
            List {
                ForEach(viewModel.collections) { item in
                    NFTCollectionCell(model: item)
                        .onTapGesture {
                            viewModel.didSelectItem(item)
                        }
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .padding(.top, 20)
            .listRowSpacing(8)
            .listStyle(.plain)
        }
        .safeAreaTopBackground()
        .applyCatalogSort(
            placement: .safeAreaTop,
            didTapName: viewModel.applySortByName,
            didTapNFTCount: viewModel.applySortByNFTCount
        )
        .task {
            await viewModel.loadCollections()
        }
    }
}

#Preview {
    @Previewable let obsAPI: ObservedNetworkClient = {
        let api = DefaultNetworkClient()
        return .init(api: api)
    }()
    
    CatalogView(
        api: .mock,
        push: { _ in }
    )
}
