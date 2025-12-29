//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct CatalogView: View {
    private static let catalogSortOptionKey: String = "catalogSortOptionKey"
    
    @State private var viewModel: CatalogViewModel
    @AppStorage(catalogSortOptionKey) private var sortOption: CatalogSortActionsViewModifier.SortOption = .name
    
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
        
        viewModel.setSortOption(sortOption)
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            List {
                ForEach(viewModel.visibleCollections) { item in
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
            .animation(.easeInOut(duration: 0.15), value: viewModel.visibleCollections)
        }
        .task(priority: .userInitiated) {
            await viewModel.loadCollections()
        }
        .safeAreaTopBackground()
        .applyCatalogSort(
            placement: .safeAreaTop,
            activeSortOption: $sortOption
        )
        .onChange(of: sortOption) { viewModel.setSortOption(sortOption) }
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
