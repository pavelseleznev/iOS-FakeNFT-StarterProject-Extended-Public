//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct CatalogView: View {
    let appContainer: AppContainer
    let push: (Page) -> Void
    
    @StateObject private var viewModel = CatalogViewModel()
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.collections) { item in
                    NFTCollectionCell(model: item)
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
            didTapName: {},
            didTapNFTCount: {}
        )
    }
}
