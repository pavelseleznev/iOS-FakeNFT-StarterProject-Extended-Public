//
//  NFTDetailScrollViewHandlerView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

fileprivate let threshold: CGFloat = 100

struct NFTDetailScrollViewHandlerView: View, @MainActor Equatable {
	static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.isImageDissapeared == rhs.isImageDissapeared &&
		lhs.isImageFullScreen == rhs.isImageFullScreen
	}
	
	private let mainGeo: GeometryProxy
	private let scrollCoordinateSpace: String

	@Binding private var isImageFullScreen: Bool
	@Binding private var isImageDissapeared: Bool
	
	private let dissapearThreshold: CGFloat
	
	init(
		mainGeo: GeometryProxy,
		scrollCoordinateSpace: String,
		isImageFullScreen: Binding<Bool>,
		isImageDissapeared: Binding<Bool>
	) {
		self.mainGeo = mainGeo
		self.scrollCoordinateSpace = scrollCoordinateSpace
		self._isImageFullScreen = isImageFullScreen
		self._isImageDissapeared = isImageDissapeared
		
		self.dissapearThreshold = -mainGeo.size.width + threshold
	}
	
	var body: some View {
		GeometryReader { geo in
			let offset = geo.frame(in: .named(scrollCoordinateSpace)).minY
			
			Color.clear
				.onChange(of: offset) { _, newValue in
					withAnimation(Constants.defaultAnimation) {
						if newValue > threshold {
							isImageFullScreen = true
						} else if newValue < -threshold {
							isImageFullScreen = false
						}
						
						if newValue < dissapearThreshold {
							isImageDissapeared = true
						} else if newValue > dissapearThreshold {
							isImageDissapeared = false
						}
					}
				}
		}
		.frame(height: 0)
	}
}

#if DEBUG
#Preview {
	GeometryReader { mainGeo in
		NFTDetailScrollViewHandlerView(
			mainGeo: mainGeo,
			scrollCoordinateSpace: "scroll",
			isImageFullScreen: .constant(false),
			isImageDissapeared: .constant(false)
		)
	}
}
#endif
