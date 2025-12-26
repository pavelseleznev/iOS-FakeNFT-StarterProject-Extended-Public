//
//  CoordinatorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct CoordinatorView: View {
	@AppStorage("appLaunchCount") var launchCount = 0
	@State private var coordinator: Coordinator
	
	var body: some View {
		NavigationStack(path: $coordinator.path) {
			coordinator.build(.splash)
				.navigationDestination(for: Page.self) { page in
					coordinator.build(page)
						.customNavigationBackButton(
							isTabView: coordinator.path.last == .tabView,
							backAction: coordinator.pop
						)
						.onAppear(perform: performLaunchAction)
						.applyAppRatingView(
							isPresented: $coordinator.ratingViewIsPresented,
							didRateCalled: didRate
						)
				}
				.sheet(item: $coordinator.sheet) { sheet in
					coordinator.build(sheet)
				}
				.fullScreenCover(
					item: $coordinator.fullScreencover
				) { fullScreenCover in
					coordinator.build(fullScreenCover)
				}
		}
	}
	
	init() {
		let api = ObservedNetworkClient()
		let nftStorage = NFTStorage()
		let nft = NFTService(api: api, storage: nftStorage)
		let appContainer = AppContainer(nftService: nft, api: api)
		_coordinator = State(initialValue: .init(appContainer: appContainer))
	}
	
	private func performLaunchAction() {
		launchCount += 1
		if ratePresentConditionIsTrue {
			withAnimation(.easeInOut(duration: 0.15).delay(0.5)) {
				coordinator.ratingViewIsPresented = true
			}
		}
	}
	
	private var ratePresentConditionIsTrue: Bool {
		launchCount % 5 == 0
	}
	
	private func didRate(rating: Int) {
		// TODO: rate implementation here
	}
}

#Preview {
	CoordinatorView()
}

extension View {
	func customNavigationBackButton(
		isTabView: Bool,
		backAction: @escaping () -> Void
	) -> some View {
		self
			.navigationBarBackButtonHidden()
			.toolbar {
				if !isTabView {
					ToolbarItem(placement: .cancellationAction) {
						Button(action: backAction) {
							Image.chevronLeft
								.font(.chevronLeftIcon)
						}
						.tint(.ypBlack)
					}
				}
			}
	}
}
