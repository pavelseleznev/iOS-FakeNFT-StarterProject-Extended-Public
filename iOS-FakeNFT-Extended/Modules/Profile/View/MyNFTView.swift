//
//  MyNFTView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import SwiftUI

fileprivate let myNFTSortOptionKey: String = "myNFTSortOptionKey"

struct MyNFTView: View {
    @State private var viewModel: MyNFTViewModel
	@StateObject private var debouncer = DebouncingViewModel()
    
	@AppStorage(myNFTSortOptionKey) private var sortOption: ProfileSortActionsViewModifier.SortOption = .name
    
	init(
		favoritesService: NFTsIDsServiceProtocol,
		loadNFT: @escaping @Sendable (String) async throws -> NFTResponse,
		loadPurchasedNFTs: @escaping @Sendable () async -> Set<String>,
		initialNFTsIDs: Set<String>
	) {
		_viewModel = State(
			initialValue: .init(
				favouritesService: favoritesService,
				loadNFT: loadNFT,
				loadPurchasedNFTs: loadPurchasedNFTs,
				initialNFTsIDs: initialNFTsIDs
			)
		)
    }
    
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			let contentIsEmpty = viewModel.filteredKeys.isEmpty
			ScrollView {
				LazyVStack(spacing: 0) {
					ForEach(viewModel.filteredKeys, id: \.self) { key in
						let item = viewModel.items[key] ?? nil
						let model = viewModel.isLoaded ? item : nil
						let isFavourite = viewModel.isLoaded ? item?.isFavorite : nil
						
						NFTMyCellView(
							model: model?.nft,
							isFavourited: isFavourite,
							likeAction: { viewModel.didTapLikeButton(item) }
						)
						.id("\(key)-\(isFavourite ?? false)")
						.frame(height: 140)
					}
				}
				.id(viewModel._kickUIUpdate)
				.animation(
					Constants.defaultAnimation,
					value: viewModel.filteredKeys
				)
			}
			.scrollContentBackground(.hidden)
			.scrollIndicators(.hidden)
			.scrollDismissesKeyboard(.interactively)
			.overlay {
				ZStack {
					if contentIsEmpty {
						EmptyContentView(type: .noMyNFTs)
							.transition(.scale.combined(with: .opacity))
					}
				}
				.animation(.default, value: contentIsEmpty)
			}
			.overlay {
				ZStack {
					if viewModel.isLoading {
						LoadingView(loadingState: .fetching)
							.transition(.scale.combined(with: .opacity))
					}
				}
				.animation(.default, value: viewModel.isLoading)
			}
		}
		.onAppear {
			viewModel.setSortOption(sortOption)
			debouncer.onDebounce = viewModel.onDebounce
		}
		.onChange(of: sortOption) { viewModel.setSortOption(sortOption) }
		.onChange(of: viewModel.sortOption) { _, newValue in sortOption = newValue }
		.applyRepeatableAlert(
			isPresented: $viewModel.loadErrorPresented,
			message: .cantGetNFTs,
			didTapRepeat: viewModel.loadNilNFTsIfNeeded
		)
		.applyProfileSort(
			activeSortOption: .init(
				get: { viewModel.sortOption },
				set: { viewModel.setSortOption($0) }
			),
			placement: .toolbar
		)
		.task(priority: .userInitiated) { await viewModel.loadPurchasedNFTs() }
		.searchable(
			text: $debouncer.text,
			placement: .navigationBarDrawer(displayMode: .always),
			prompt: .search
		)
		.toolbar {
			ToolbarItem(placement: .title) {
                Text(viewModel.myNFTs)
					.font(.bold17)
			}
		}
		.onReceive(
			NotificationCenter.default.publisher(for: .purchasedDidUpdate),
			perform: viewModel.purchasedDidUpdate
		)
		.allowsHitTesting(!viewModel.isLoading)
    }
}

#if DEBUG
#Preview {
	MyNFTView(
		favoritesService: NFTsIDsService(api: .mock, kind: .favorites),
		loadNFT: { _ in .mock },
		loadPurchasedNFTs: { [] },
		initialNFTsIDs: []
	)
}
#endif
