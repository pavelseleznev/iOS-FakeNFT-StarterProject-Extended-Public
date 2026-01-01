//
//  LoadingShimmerPhase.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 23.12.2025.
//

import SwiftUI
import Combine

fileprivate enum LoadingShimmerPhase {
	case start, shine1, peak, shine2, end
	
	var progress: CGFloat {
		switch self {
		case .start:
			0
		case .shine1:
			0.5
		case .peak:
			1
		case .shine2:
			1.5
		case .end:
			2
		}
	}
	
	var nextPhase: Self {
		switch self {
		case .start:
			.shine1
		case .shine1:
			.peak
		case .peak:
			.shine2
		case .shine2:
			.end
		case .end:
			.start
		}
	}
}

struct LoadingShimmerPlaceholderView: View {
	@State private var animationPhase: LoadingShimmerPhase = .start
	@State private var cancellableTimer: Cancellable?
	
	var body: some View {
		GeometryReader {
			let size = $0.size
			
			RoundedRectangle(cornerRadius: 4)
				.fill(.ypBackgroundUniversal)
				.overlay {
					RoundedRectangle(cornerRadius: 8)
						.fill(.ypBlackUniversal.opacity(0.3))
						.mask(animatedGradient(size: size))
				}
		}
		.onAppear {
			cancellableTimer = Timer
				.publish(every: 0.2, on: .main, in: .common)
				.autoconnect()
				.sink { _ in
					withAnimation(animationPhase != .end ? .linear(duration: 0.2) : nil) {
						animationPhase = animationPhase.nextPhase
					}
				}
		}
		.onDisappear { cancellableTimer?.cancel() }
	}
	
	private func animatedGradient(size: CGSize) -> some View {
		LinearGradient(
			colors: [
				.clear,
				.ypBackgroundUniversal.opacity(0.6),
				.ypWhiteUniversal.opacity(0.9),
				.ypBackgroundUniversal.opacity(0.6),
				.clear
			],
			startPoint: .leading,
			endPoint: .trailing
		)
		.offset(
			x: animationPhase.progress * size.width - size.width
		)
	}
}

#if DEBUG
#Preview("Loading") {
	LoadingShimmerPlaceholderView()
}
#endif
