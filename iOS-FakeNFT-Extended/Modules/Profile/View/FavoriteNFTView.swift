//
//  FavoriteNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/20/25.
//

import SwiftUI

struct FavoriteNFTView: View {
    
    @State private var viewModel: FavoriteNFTViewModel
	@StateObject private var debouncer = DebouncingViewModel()
    
	init(service: NFTServiceProtocol) {
		_viewModel = State(initialValue: FavoriteNFTViewModel(service: service))
    }
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
			ScrollView(.vertical) {
				LazyVGrid(
					columns: columns,
					spacing: 20
				) {
					ForEach(viewModel.filteredKeys, id: \.self) { key in
						let item = viewModel.items[key] ?? nil
						
						NFTCompactCellView(
							model: item,
							isFavourited: item == nil ? nil : true,
							likeAction: { viewModel.didTapLikeButton(for: item) }
						)
						.frame(height: 80)
					}
				}
				.animation(
					Constants.defaultAnimation,
					value: viewModel.filteredKeys
				)
				.safeAreaPadding([.leading, .top])
			}
			.scrollContentBackground(.hidden)
			.scrollIndicators(.hidden)
			.scrollDismissesKeyboard(.interactively)
			.overlay {
				if viewModel.filteredKeys.isEmpty {
					EmptyContentView(type: .noFavoriteNFTs)
				}
			}
        }
		.applyRepeatableAlert(
			isPresented: $viewModel.loadErrorPresented,
            message: viewModel.removeFavoriteErrorMessage,
			didTapRepeat: viewModel.loadNilNFTsIfNeeded
		)
		.onAppear {
			debouncer.onDebounce = viewModel.onDebounce
		}
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.favouritedNFTs)
					.font(.bold17)
            }
        }
		.searchable(
			text: $debouncer.text,
			placement: .navigationBarDrawer(displayMode: .always),
			prompt: .search
		)
        .task(priority: .userInitiated) { await viewModel.loadFavorites() }
		.onReceive(
			NotificationCenter.default.publisher(for: .favouritesDidUpdate),
			perform: viewModel.favouritesDidUpdate
		)
    }
}
