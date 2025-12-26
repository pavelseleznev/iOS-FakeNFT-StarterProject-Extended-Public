//
//  SplashView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct SplashView: View {
	@State private var dataLoadingErrorIsPresented = false
	
	let appContainer: AppContainer
	let onComplete: () -> Void
	private let animation: Animation = .easeInOut(duration: 0.15)

	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			let state = appContainer.api.loadingState
			Image(.vector)
				.scaleEffect(state == .idle ? 1 : 0)
				.opacity(state == .idle ? 1 : 0.1)
				.overlay {
					ProgressView()
						.scaleEffect(state != .idle ? 1.5 : 0)
						.progressViewStyle(.circular)
				}
		}
		.animation(animation, value: appContainer.api.loadingState)
		.task(priority: .userInitiated) {
			await loadUserData()
		}
		.applyRepeatableAlert(
			isPresneted: $dataLoadingErrorIsPresented,
			message: .cantGetProfileData,
			didTapRepeat: {
				Task(priority: .userInitiated) { await loadUserData() }
			}
		)
		.transition(.opacity)
	}
	
	private func loadUserData() async {
		do {
			let profile = try await appContainer.api.getProfile()
			let cart = try await appContainer.api.getOrder()
			
			await appContainer.nftService
				.didLoadUserData(
					likes: profile.likes,
					purchased: profile.nfts,
					cart: cart.nftsIDs
				)
			
			onComplete()
		} catch {
			guard !(error is CancellationError) else { return }
			withAnimation(animation) {
				dataLoadingErrorIsPresented = true
			}
		}
	}
}

#if DEBUG
#Preview {
	SplashView(
		appContainer: .init(
			nftService: NFTService(api: .mock, storage: NFTStorage()),
			api: .mock
		),
		onComplete: {}
	)
}
#endif
