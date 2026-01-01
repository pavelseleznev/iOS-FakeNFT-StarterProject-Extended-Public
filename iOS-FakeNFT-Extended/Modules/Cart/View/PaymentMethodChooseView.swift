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
	
	private var content: some View {
		ScrollView(.vertical) {
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
			.task(priority: .high) {
				await viewModel.loadPaymentMethods()
			}
			.padding(.horizontal)
			.safeAreaPadding(.top)
		}
	}
	
	@ViewBuilder
	private func emptyView() -> some View {
		if viewModel.visibleCurrencies.isEmpty {
			EmptyContentView(type: .currencies)
				.transition(
					.opacity
						.combined(with: .scale)
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
