//
//  CoordinatorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct CoordinatorView: View {
	@AppStorage(Constants.appLaunchCountKey) private var launchCount = 0
	@AppStorage(Constants.ratingIsAlreadyPresentedThisLaunchKey) private var ratingIsAlreadyPresentedThisLaunch = false
	@State private var coordinator: Coordinator
	
	var body: some View {
		NavigationStack(path: coordinator.bindingPath) {
			coordinator.build(coordinator.rootPage)
				.navigationDestination(for: Page.self) { page in
					coordinator.build(page)
						.customNavigationBackButton(
							hasNotBackButton: coordinator.bindingPath.wrappedValue.last?.hasNotBackButton,
							backAction: coordinator.pop
						)
						.onAppear(perform: performLaunchAction)
						.applyAppRatingView(
							isPresented: coordinator.bindingRatingViewIsPresented,
							didRateCalled: didRate
						)
				}
				.sheet(item: coordinator.bindingSheet) { sheet in
					coordinator.build(sheet)
				}
				.fullScreenCover(item: coordinator.bindingsFullScreencover) { fullScreenCover in
					coordinator.build(fullScreenCover)
				}
		}
	}
	
	init() {
		let api = ObservedNetworkClient()
		let nftStorage = NFTStorage()
		let nft = NFTService(api: api, storage: nftStorage)
		let appContainer = AppContainer(
			nftService: nft,
			api: api
		)
		_coordinator = State(initialValue: .init(appContainer: appContainer))
		
		launchCount += 1
		ratingIsAlreadyPresentedThisLaunch = false
	}
	
	private func performLaunchAction() {
		guard
			coordinator.bindingPath.wrappedValue.last == .tabView,
			!ratingIsAlreadyPresentedThisLaunch,
			ratePresentConditionIsTrue
		else { return }
		
		withAnimation(Constants.defaultAnimation.delay(0.5)) {
			ratingIsAlreadyPresentedThisLaunch = true
			coordinator.bindingRatingViewIsPresented.wrappedValue = true
		}
	}
	
	private var ratePresentConditionIsTrue: Bool {
		withAnimation(Constants.defaultAnimation) {
			launchCount % 5 == 0
		}
	}
	
	private func didRate(rating: Int) {
		// TODO: rate implementation here
	}
}

#Preview {
	CoordinatorView()
}
