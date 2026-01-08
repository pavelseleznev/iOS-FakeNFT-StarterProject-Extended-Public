//
//  View+Extensions.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 09.12.2025.
//

import SwiftUI

extension View {
	func safeAreaTopBackground() -> some View {
		GeometryReader { geo in
			ZStack(alignment: .top) {
				self
				
				Rectangle()
					.fill(.ypWhite)
					.frame(height: geo.safeAreaInsets.top)
					.ignoresSafeArea(edges: .top)
					.offset(y: -geo.safeAreaInsets.top - 16)
					.blur(radius: 5, opaque: false)
				
				Rectangle()
					.fill(.ypWhite)
					.frame(height: geo.safeAreaInsets.top - 32)
					.ignoresSafeArea(edges: .top)
					.offset(y: -geo.safeAreaInsets.top - 16)
			}
		}
	}
}
