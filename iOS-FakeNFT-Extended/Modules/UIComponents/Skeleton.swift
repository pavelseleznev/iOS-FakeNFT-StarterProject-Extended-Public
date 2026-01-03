//
//  Skeleton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

extension View {
	func applySkeleton<T>(_ data: T?) -> some View {
		self
			.opacity(data == nil ? 0 : 1)
			.overlay {
				if data == nil {
					LoadingShimmerPlaceholderView()
						.transition(.scale.combined(with: .opacity))
				}
			}
	}
}

#Preview {
	@Previewable @State var data: String?
	
	ZStack {
		Image(.big)
			.resizable()
			.aspectRatio(1, contentMode: .fit)
			.frame(width: 300, height: 300)
			.applySkeleton(data)
	}
	.task(priority: .userInitiated) {
		try? await Task.sleep(for: .seconds(2))
		data = "Hello, World!"
	}
}
