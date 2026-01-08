//
//  SplashView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

fileprivate let loadingCommentDuration: TimeInterval = 3
fileprivate let blinkingAppIconSize: CGFloat = 80

struct SplashView: View {
	@State private var viewModel: SplashViewModel
	private let timer = Timer.publish(
		every: loadingCommentDuration,
		on: .main,
		in: .common
	).autoconnect()
	
	init(onComplete: @escaping () -> Void) {
		_viewModel = .init(
			initialValue: .init(onComplete: onComplete)
		)
	}

	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			Group {
				SplashBackgroundView()
				
				Image(.vector)
					.scaleEffect(viewModel.isLoading ? 0 : 1)
					.opacity(viewModel.isLoading ? 0.1 : 1)
				
				VStack(spacing: 16) {
					BlinkingAppIcon(imageSize: blinkingAppIconSize)
					
					loadingCommentView
					
					ProgressView()
						.scaleEffect(1.5)
						.progressViewStyle(.circular)
				}
				.scaleEffect(viewModel.isLoading ? 1 : 0)
			}
			.animation(Constants.defaultAnimation, value: viewModel.isLoading)
			.scaleEffect(viewModel.performOnDissapear ? 3 : 1)
			.opacity(viewModel.performOnDissapear ? 0 : 1)
		}
		.task(priority: .utility) { await viewModel.waitAnimations() }
		.transition(.opacity)
		.onReceive(timer, perform: viewModel.timerTick)
	}
	
	private var loadingCommentText: some View {
		Text(viewModel.currentLoadingComment.title)
			.font(.bold17)
			.foregroundStyle(.ypBlack)
			.multilineTextAlignment(.center)
			.frame(width: 200)
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
	SplashView(onComplete: {})
}
#endif
