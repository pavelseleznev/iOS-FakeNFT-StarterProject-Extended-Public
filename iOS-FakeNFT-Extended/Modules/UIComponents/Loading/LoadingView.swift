//
//  LoadingView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

struct LoadingView: View {
	private let loadingState: LoadingState
	private let onReload: () -> Void
	
	init(loadingState: LoadingState, onReload: @escaping () -> Void = {}) {
		self.loadingState = loadingState
		self.onReload = onReload
	}

	var body: some View {
		RoundedRectangle(cornerRadius: 16)
			.fill(Material.ultraThinMaterial)
			.overlay {
				switch loadingState {
				case .idle:
					Color.clear
				case .fetching:
					ProgressView()
						.scaleEffect(1.4)
						.progressViewStyle(.circular)
						.transition(.scale.combined(with: .opacity))
				case .error:
					Button(action: onReload) {
						Image(systemName: "arrow.counterclockwise")
							.font(.bold32)
							.foregroundStyle(.cyan)
							.rotationEffect(.degrees(-90))
					}
					.disabled(loadingState != .error)
					.transition(.scale.combined(with: .opacity))
				}
			}
			.frame(width: 82, height: 82)
			.shadow(color: .ypBlackUniversal.opacity(0.8), radius: 80)
			.scaleEffect(loadingState != .idle ? 1 : 0)
			.opacity(loadingState != .idle ? 1 : 0)
			.animation(Constants.defaultAnimation, value: loadingState)
	}
}

#if DEBUG
#Preview {
	@Previewable @State var loadingState: LoadingState = .idle
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button {
			if loadingState != .fetching {
				loadingState = .fetching
			} else {
				loadingState = .error
			}
		} label: {
			Text("ToggleState")
		}
	}
	.overlay {
		LoadingView(
			loadingState: loadingState,
			onReload: {
				loadingState = .fetching
			}
		)
	}
	.onChange(of: loadingState) {
		if loadingState == .fetching {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				loadingState = .error
			}
		}
	}
}
#endif
