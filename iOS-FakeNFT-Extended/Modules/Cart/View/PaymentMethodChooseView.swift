//
//  PaymentMethodChooseView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct PaymentMethodChooseView: View {
	
	@State private var viewModel: PaymentMethodChooseViewModel
	
	init(
		currenciesService: CurrenciesServiceProtocol,
		cartService: CartServiceProtocol,
		onComplete: @escaping () -> Void
	) {
		_viewModel = .init(
			initialValue: .init(
				currenciesService: currenciesService,
				cartService: cartService,
				onComplete: onComplete
			)
		)
	}
	
	private let columns: [GridItem] = [
		.init(.flexible(), spacing: 8),
		.init(.flexible())
	]
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			VStack {
				content
					.overlay(content: emptyView)
				
				Spacer()
				
				PaymentMethodChooseBottomBar(
					didTapBuyButton: viewModel.didTapBuyButton,
					isLoaded: !viewModel.currencies.isEmpty,
					currencyAtLeastOneSelected: viewModel.selectedCurrency != nil,
					paymentInProgress: viewModel.paymentInProgress
				)
			}
		}
		.task(priority: .userInitiated) {
			await viewModel.loadPaymentMethods()
		}
		.onReceive(
			NotificationCenter.default.publisher(for: .currentUserDidUpdate),
			perform: viewModel.updatePaymentMethods
		)
		.toolbar {
			ToolbarItem(placement: .title) {
				Text(.choosePaymentMethod)
					.font(.bold17)
					.foregroundStyle(.ypBlack)
			}
		}
		.applyRepeatableAlert(
			isPresneted: $viewModel.alertIsPresented,
			message: .failedToPay,
			didTapRepeat: viewModel.didTapBuyButton
		)
	}
	
	@ViewBuilder
	private var content: some View {
		ScrollView(.vertical) {
			if !viewModel.currencies.isEmpty {
				LazyVGrid(
					columns: columns,
					spacing: 8
				) {
					ForEach(viewModel.currencies, id: \.id) { model in
						PaymentMethodChooseCell(
							currency: model.currency,
							selected: viewModel.selectedCurrency == model
						)
						.onTapGesture {
							viewModel.setCurrency(model)
						}
						.id(model.id)
					}
				}
				.padding(.horizontal)
				.safeAreaPadding(.top)
				.transition(.scale.combined(with: .opacity))
			} else {
				Color.clear
			}
		}
	}
	
	@ViewBuilder
	private func emptyView() -> some View {
		if viewModel.currencies.isEmpty {
			EmptyContentView(type: .currencies)
				.transition(
					.scale
						.combined(with: .opacity)
						.animation(Constants.defaultAnimation.delay(0.25))
				)
		}
	}
}

#if DEBUG
#Preview {
	@Previewable let api = ObservedNetworkClient()
	
	NavigationStack {
		PaymentMethodChooseView(
			currenciesService: CurrenciesService(api: api),
			cartService: CartService(
				orderService: NFTsIDsService(
					api: api,
					kind: .order
				),
				api: api
			),
			onComplete: {}
		)
	}
}
#endif
