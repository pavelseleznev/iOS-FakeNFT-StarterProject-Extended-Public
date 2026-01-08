//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

fileprivate let mockData: [NFTCollectionItemResponse] = [.mock1, .mock2, .mock3, .mock1, .mock2, .mock3]

struct CatalogView: View {
	private static let catalogSortOptionKey: String = "catalogSortOptionKey"
	
	@State private var viewModel: CatalogViewModel
	@StateObject private var deboucner = DebouncingViewModel()
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
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			List {
				let data = viewModel.visibleCollections
				ForEach(data.isEmpty ? mockData : data, id: \.id) { item in
					CatalogCollectionCell(model: item, isMock: data.isEmpty)
						.onTapGesture {
							viewModel.didSelectItem(item)
						}
						.listRowInsets(.init())
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
				}
			}
			.animation(
				Constants.defaultAnimation,
				value: viewModel.visibleCollections
			)
			.listRowSpacing(8)
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.scrollIndicators(.hidden)
			.safeAreaPadding(.top)
			.scrollDismissesKeyboard(.interactively)
		}
		.onAppear {
			deboucner.onDebounce = viewModel.onDebounce
			viewModel.setSortOption(sortOption)
		}
		.task(priority: .userInitiated) {
			await viewModel.loadCollections()
		}
		.safeAreaTopBackground()
		.applyCatalogSort(
			placement: .safeAreaTop,
			activeSortOption: $sortOption,
			searchText: $deboucner.text
		)
		.applyRepeatableAlert(
			isPresented: $viewModel.errorIsPresented,
			message: .nftCollection, // TODO: add custom & Localize
			didTapRepeat: {
				Task {
					await viewModel.loadCollections()
				}
			}
		)
		.toolbar(.hidden)
		.onChange(of: sortOption) { viewModel.setSortOption(sortOption) }
	}
}

#Preview {
	CatalogView(
		api: .mock,
		push: {_ in}
	)
}
