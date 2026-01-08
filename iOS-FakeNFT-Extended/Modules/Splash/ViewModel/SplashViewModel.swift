//
//  SplashViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

@MainActor
@Observable
final class SplashViewModel {
	private let onComplete: () -> Void
	private(set) var currentLoadingComment: SplashLoadingComment = .allCases.randomElement()!
	private(set) var isLoading = false
	private(set) var performOnDissapear = false
	
	init(onComplete: @escaping () -> Void) {
		self.onComplete = onComplete
	}
}

// MARK: - SplashViewModel Extensions
// --- internal methods ---
extension SplashViewModel {
	func waitAnimations() async {
		do {
			HapticPerfromer.shared.play(.splashWave)
			
			isLoading = true
			try await Task.sleep(for: Constants.splashPresentationDuration)
			isLoading = false
			withAnimation(.easeInOut(duration: 0.5)) {
				performOnDissapear = true
			}
			try await Task.sleep(for: .seconds(0.5))
			onComplete()
		} catch is CancellationError {
			print("\(#function) cancelled")
		} catch {
			print("\(#function) unexpected error: \(error)")
		}
	}
	
	func timerTick(_: Date) {
		withAnimation(Constants.defaultAnimation) {
			currentLoadingComment = currentLoadingComment.next
		}
	}
}

// --- internal data getters ---
extension SplashViewModel {
	@inline(__always)
	var randomTransition: AnyTransition {
		[
			AnyTransition.asymmetric(
				insertion: .scale.combined(with: .push(from: .leading)),
				removal: .scale.combined(with: .move(edge: .trailing))
			),
			AnyTransition.scale
		].randomElement() ?? .scale
	}
}
