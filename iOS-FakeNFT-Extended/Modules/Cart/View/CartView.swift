//
//  CartView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct CartView: View {
	private static let cartSortOptionKey: String = "cartSortOptionKey"
	
	@State private var viewModel: CartViewModel
	@AppStorage(cartSortOptionKey) private var sortOption: CartSortActionsViewModifier.SortOption = .name
	
	init(
		nftService: NFTServiceProtocol,
		push: @escaping (Page) -> Void
	) {
		_viewModel = .init(
			initialValue: .init(nftService: nftService, push: push)
		)
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			List(
				Array(viewModel.visibleNfts.enumerated()),
				id: \.offset
			) { index, nft in
				NFTCartCellView(
					model: nft,
					cartAction: {
						viewModel.setNFTForRemoval(nft)
					}
				)
				.listRowBackground(Color.clear)
				.listRowInsets(.init())
				.listRowSeparator(.hidden)
			}
			.scrollContentBackground(.hidden)
			.listStyle(.plain)
			.listRowSpacing(32)
			.safeAreaPadding(.bottom)
			.scrollIndicators(.hidden)
			.overlay(content: emptyCartView)
		}
		.task(priority: .userInitiated) { await viewModel.updateIDs() }
		.task(priority: .userInitiated) { await viewModel.loadNilNFTs() }
		.onDisappear {
			viewModel.clearNftsLoadTask()
			viewModel.clearIdsUpdateTask()
		}
		.onChange(of: sortOption) {
			viewModel.setSortOption(sortOption)
		}
		.onAppear {
			viewModel.setSortOption(sortOption)
		}
		.animation(Constants.defaultAnimation, value: viewModel.visibleNfts)
		.safeAreaTopBackground()
		.applyCartSort(
			placement: .safeAreaTop,
			activeSortOption: $sortOption
		)
		.safeAreaInset(edge: .bottom, content: cartActionContent)
		.allowsHitTesting(!viewModel.removalApproveAlertIsPresented)
		.blur(radius: viewModel.removalApproveAlertIsPresented ? 40 : 0)
		.overlay {
			if viewModel.removalApproveAlertIsPresented {
				CartNFTRemovalApproveAlertView(
					model: viewModel.modelForRemoval,
					removeAction: {
						viewModel.removeNFTFromCart()
						viewModel.nftDismissAction()
					},
					dismissAction: viewModel.nftDismissAction
				)
				.transition(.scale.combined(with: .opacity))
			}
		}
		.toolbar(.hidden)
		.applyRepeatableAlert(
			isPresneted: $viewModel.dataLoadingErrorIsPresented,
			message: .cantGetData,
			didTapRepeat: viewModel.reloadCart
		)
	}
	
	@ViewBuilder
	private func emptyCartView() -> some View {
		if viewModel.nftCount == 0 {
			EmptyContentView(type: .cart)
		}
	}
	
	private func cartActionContent() -> some View {
		CartBottomToolbar(
			nftCount: viewModel.nftCount,
			costLabel: viewModel.cartCostLabel,
			performPayment: viewModel.performPayment,
			isLoaded: viewModel.isLoaded
		)
	}
}

#if DEBUG
#Preview {
	@Previewable let api = ObservedNetworkClient()
	@Previewable let storage = NFTStorage()
	
	CartView(
		nftService: NFTService(api: api, storage: storage),
		push: {_ in}
	)
	.task(priority: .userInitiated) {
		do {
			for id in try await api.getOrder().nftsIDs {
				await storage.addToCart(id: id)
			}
		} catch { print(error.localizedDescription) }
	}
}
#endif
