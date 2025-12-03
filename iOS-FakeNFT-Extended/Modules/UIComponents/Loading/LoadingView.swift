//
//  LoadingView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

struct LoadingView: View {
	let loadingState: LoadingState

	var body: some View {
		RoundedRectangle(cornerRadius: 16)
			.fill(Material.ultraThinMaterial)
			.overlay {
				ProgressView()
					.scaleEffect(1.4)
					.progressViewStyle(.circular)
			}
			.frame(width: 82, height: 82)
			.shadow(color: .ypBlackUniversal.opacity(0.8), radius: 80)
			.scaleEffect(loadingState == .fetching ? 1 : 0)
			.opacity(loadingState == .fetching ? 1 : 0)
			.animation(.easeInOut(duration: 0.15), value: loadingState)
	}
}

#Preview {
	@Previewable @State var loadingState = LoadingState.idle
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button {
			if loadingState != .fetching {
				loadingState = .fetching
			} else {
				loadingState = [.error, .idle].randomElement()!
			}
		} label: {
			Text("ToggleState")
		}
	}
	.overlay {
		LoadingView(loadingState: loadingState)
	}
}
