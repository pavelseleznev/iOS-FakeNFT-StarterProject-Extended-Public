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
	@State private var isAppeared = false
	
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
			
			if isAppeared {
				Color.clear
					.frame(width: 0, height: 0)
					.task(priority: .utility) { await viewModel.waitAnimations() }
			}
			
			ZStack {
				Image(.vector)
					.scaleEffect(viewModel.isLoading ? 0 : 1)
					.opacity(viewModel.isLoading ? 0 : 1)
				
				VStack(spacing: 16) {
					BlinkingAppIcon(imageSize: blinkingAppIconSize)
					
					loadingCommentView
					
					ProgressView()
						.scaleEffect(1.5)
						.progressViewStyle(.circular)
				}
				.scaleEffect(viewModel.isLoading ? 1 : 0)
				.opacity(viewModel.isLoading ? 1 : 0)
			}
			.animation(.default, value: viewModel.isLoading)
			.scaleEffect(viewModel.performOnDissapear ? 0 : 1)
			.opacity(viewModel.performOnDissapear ? 0 : 1)
		}
		.overlay {
			if isAppeared && !viewModel.performOnDissapear {
				SplashBackgroundView()
					.transition(
						.asymmetric(
							insertion: .opacity.animation(.easeInOut(duration: 2)),
							removal:
								.scale(scale: 3)
								.combined(with: .opacity)
								.animation(Constants.defaultAnimation)
						)
					)
					.drawingGroup()
			}
		}
		.ignoresSafeArea()
		.transition(.opacity)
		.onReceive(timer, perform: viewModel.timerTick)
		.onAppear(perform: onAppear)
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
	
	private func onAppear() {
		isAppeared = true
	}
}

#if DEBUG
#Preview("Splash") {
	SplashView(onComplete: {})
}
#endif
