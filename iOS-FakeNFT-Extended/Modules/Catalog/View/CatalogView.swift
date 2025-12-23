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
            .listRowSpacing(8)
            .listStyle(.plain)
        }
        .padding(.top, 20)
        .applyCatalogSort(
            placement: .safeAreaTop,
            didTapName: viewModel.applySortByName,
            didTapNFTCount: viewModel.applySortByNFTCount
        )
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
