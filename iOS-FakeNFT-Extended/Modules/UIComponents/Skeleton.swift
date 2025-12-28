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
