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
	@StateObject private var debouncer = DebouncingViewModel()
	@AppStorage(cartSortOptionKey) private var sortOption: CartSortActionsViewModifier.SortOption = .name
	
	init(
		nftService: NFTServiceProtocol,
		cartService: CartServiceProtocol,
		onSubmit: @escaping () -> Void
	) {
		_viewModel = .init(
			initialValue: .init(
				nftService: nftService,
				cartService: cartService,
				onSubmit: onSubmit
			)
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
				.listCellModifiers()
			}
			.listModifiers()
			.overlay(content: emptyCartView)
		}
		.animation(Constants.defaultAnimation, value: viewModel.visibleNfts)
		.toolbar(.hidden)
		.task(priority: .userInitiated) {
			await viewModel.performCartUpdateIfNeeded()
		}
		.onReceive(
			NotificationCenter.default.publisher(for: .cartDidUpdate),
			perform: viewModel.update
		)
		.task(priority: .userInitiated) { await viewModel.loadNilNFTs() }
		.onChange(of: sortOption, viewModel.setSortOption)
		.safeAreaTopBackground()
		.applyCartSort(
			placement: .safeAreaTop,
			activeSortOption: $sortOption,
			searchText: $debouncer.text
		)
		.safeAreaInset(edge: .bottom, content: cartActionContent)
		.allowsHitTesting(!viewModel.removalApproveAlertIsPresented)
		.blur(radius: viewModel.removalApproveAlertIsPresented ? 40 : 0)
		.overlay(content: removalApproveContent)
		.toolbar(.hidden)
		.applyRepeatableAlert(
			isPresented: $viewModel.dataLoadingErrorIsPresented,
			message: .cantGetData,
			didTapRepeat: viewModel.reloadCart
		)
		.onDisappear(perform: viewModel.viewDidDissappear)
		.onAppear {
			debouncer.onDebounce = viewModel.onDebounce
			viewModel.setSortOption(sortOption, sortOption)
			viewModel.reloadCart()
		}
	}
}

// MARK: - CartView Extensions
// --- subviews ---
private extension CartView {
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
			performPayment: viewModel.onSubmmit,
			isLoaded: viewModel.isLoaded
		)
	}
	
	@ViewBuilder
	private func removalApproveContent() -> some View {
		if viewModel.removalApproveAlertIsPresented {
			CartNFTRemovalApproveAlertView(
				model: viewModel.modelForRemoval,
				removeAction: {
					HapticPerfromer.shared.play(.notification(.success))
					viewModel.removeNFTFromCart()
					viewModel.nftDismissAction()
				},
				dismissAction: viewModel.nftDismissAction
			)
			.onAppear { HapticPerfromer.shared.play(.notification(.warning)) }
			.transition(.scale.combined(with: .opacity))
		}
	}
}

// MARK: - View helpers
private extension View {
	func listModifiers() -> some View {
		self
			.scrollContentBackground(.hidden)
			.listStyle(.plain)
			.listRowSpacing(32)
			.safeAreaPadding(.bottom)
			.scrollIndicators(.hidden)
			.scrollDismissesKeyboard(.interactively)
	}
	
	func listCellModifiers() -> some View {
		self
			.listRowBackground(Color.clear)
			.listRowInsets(.init())
			.listRowSeparator(.hidden)
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	@Previewable let api = ObservedNetworkClient()
	lazy var orderService = NFTsIDsService(
		api: api,
		kind: .order
	)
	
	lazy var nftService = NFTService(
		favouritesService: NFTsIDsService(
			api: api,
			kind: .favorites
		),
		orderService: orderService,
		loadNFT: api.getNFT
	)
	
	NavigationStack {
		CartView(
			nftService: NFTService(
				favouritesService: NFTsIDsService(
					api: api,
					kind: .favorites
				),
				orderService: orderService,
				loadNFT: api.getNFT
			),
			cartService: CartService(
				orderService: orderService,
				api: api
			),
			onSubmit: {}
		)
		.task(priority: .userInitiated) {
			do {
				let loaded = try await api.getOrder().nftsIDs
				await nftService.orderService.replace(withLoaded: loaded)
			} catch { print(error.localizedDescription) }
		}
	}
}
#endif
