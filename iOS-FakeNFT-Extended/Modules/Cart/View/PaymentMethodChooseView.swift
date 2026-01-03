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
		appContainer: AppContainer,
		push: @escaping (Page) -> Void
	) {
		_viewModel = .init(
			initialValue: .init(
				appContainer: appContainer,
				push: push
			)
		)
	}
	
	private let columns: [GridItem] = [
		.init(.flexible()),
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
					isLoaded: viewModel.isLoaded,
					currencyAtLeastOneSelected: viewModel.selectedCurrency != nil,
					paymentInProgress: viewModel.paymentInProgress
				)
			}
		}
		.animation(Constants.defaultAnimation, value: viewModel.visibleCurrencies)
		.task(priority: .userInitiated) {
			await viewModel.loadPaymentMethods()
		}
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
			if !viewModel.visibleCurrencies.isEmpty {
				LazyVGrid(
					columns: columns,
					alignment: .center,
					spacing: 7
				) {
					ForEach(
						Array(viewModel.visibleCurrencies.enumerated()),
						id: \.offset
					) { _, model in
						PaymentMethodChooseCell(
							currency: model?.currency,
							selected: viewModel.selectedCurrency == model && model != nil
						)
						.onTapGesture {
							viewModel.setCurrency(model)
						}
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
		if viewModel.visibleCurrencies.isEmpty {
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
	NavigationStack {
		PaymentMethodChooseView(
			appContainer: .init(
				nftService: NFTService(
					api: .mock,
					storage: NFTStorage()
				),
				api: .mock
			),
			push: {_ in}
		)
	}
}
#endif
