//
//  SplashView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

fileprivate let loadingCommentDuration: TimeInterval = 4

struct SplashView: View {
	@State private var viewModel: SplashViewModel
	private let timer = Timer.publish(
		every: loadingCommentDuration,
		on: .main,
		in: .common
	).autoconnect()
	
	init(
		appContainer: AppContainer,
		onComplete: @escaping () -> Void,
	) {
		_viewModel = .init(
			initialValue: .init(appContainer: appContainer, onComplete: onComplete)
		)
	}

	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			SplashBackgroundView()
			
			let state = viewModel.loadingState
			Image(.vector)
				.scaleEffect(state == .idle ? 1 : 0)
				.opacity(state == .idle ? 1 : 0.1)
			
			VStack(spacing: 16) {
				loadingCommentView
				
				ProgressView()
					.scaleEffect(1.5)
					.progressViewStyle(.circular)
			}
			.scaleEffect(state != .idle ? 1 : 0)
		}
		.animation(Constants.defaultAnimation, value: viewModel.loadingState)
		.task(priority: .utility) { await viewModel.waitAnimations() }
		.transition(.opacity)
		.onReceive(timer, perform: viewModel.timerTick)
	}
	
	private var loadingCommentText: some View {
		Text(viewModel.currentLoadingComment.title)
			.font(.bold17)
			.foregroundStyle(.ypBlack)
			.transition(viewModel.randomTransition)
			.id(viewModel.currentLoadingComment.id)
	}
	
	private var loadingCommentView: some View {
		loadingCommentText
			.opacity(0)
			.overlay {
				LoadingShimmerPlaceholderView()
					.colorScheme(.dark)
					.mask(loadingCommentText)
			}
	}
}

#if DEBUG
#Preview("Splash") {
	@Previewable let api = ObservedNetworkClient()
	
	SplashView(
		appContainer: .mock,
		onComplete: {}
	)
}
#endif
