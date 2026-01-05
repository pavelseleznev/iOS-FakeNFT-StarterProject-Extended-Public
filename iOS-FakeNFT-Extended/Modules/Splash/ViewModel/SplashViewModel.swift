//
//  SplashViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

fileprivate let loadingCommentDuration: TimeInterval = 4

@MainActor
@Observable
final class SplashViewModel {
	private let dependencies: AppContainer
	private let onComplete: () -> Void
	
	private(set) var currentLoadingComment: SplashLoadingComment = .allCases.randomElement()!
	private(set) var updateID = UUID()
	private(set) var dataLoadingErrorIsPresented = false
	
	let animation: Animation = .easeInOut(duration: 0.25)
	
	init(
		appContainer: AppContainer,
		onComplete: @escaping () -> Void
	) {
		dependencies = appContainer
		self.onComplete = onComplete
	}
}

// MARK: - SplashViewModel Extensions
// --- internal methods ---
extension SplashViewModel {
	func loadUserData() async {
		do {
			#warning("TODO: skip this by background long polling updates")

			try await dependencies.purchasedNFTsService.loadAndSave()
			try await dependencies.nftService.favouritesService.loadAndSave()
			try await dependencies.nftService.orderService.loadAndSave()
			try await dependencies.profileService.loadProfileAndSave()
			
			onComplete()
		} catch is CancellationError {
			print("\(#function) cancelled")
		} catch {
			print("\(#function) failed: \(error)")
			withAnimation(animation) {
				dataLoadingErrorIsPresented = true
			}
		}
	}
	
	func performLoadingCommentRolling() {
		let _animation = animation
		
		Timer.scheduledTimer(withTimeInterval: loadingCommentDuration, repeats: true) { _ in
			DispatchQueue.main.async {
				withAnimation(_animation) { [weak self] in
					guard let self else { return }
					currentLoadingComment = currentLoadingComment.next
					updateID = .init()
				}
			}
		}
	}
	
	func dismissError(_ state: Bool) {
		withAnimation(animation) {
			dataLoadingErrorIsPresented = state
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
	
	@inline(__always)
	var loadingState: LoadingState {
		dependencies.api.loadingState
	}
}
