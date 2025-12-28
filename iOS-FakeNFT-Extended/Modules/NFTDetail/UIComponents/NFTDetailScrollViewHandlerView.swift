//
//  NFTDetailScrollViewHandlerView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

struct NFTDetailScrollViewHandlerView: View {
	let mainGeo: GeometryProxy
	let scrollCoordinateSpace: String

	@Binding var isImageFullScreen: Bool
	@Binding var isImageDissapeared: Bool
	
	var body: some View {
		GeometryReader { geo in
			let offset = geo.frame(in: .named(scrollCoordinateSpace)).minY
			
			Color.clear
				.onChange(of: offset) { _, newValue in
					let threshold: CGFloat = 100
					
					withAnimation(Constants.defaultAnimation) {
						if newValue > threshold {
							isImageFullScreen = true
						} else if newValue < -threshold {
							isImageFullScreen = false
						}
						
						let dissapearThreshold: CGFloat = -mainGeo.size.width + 100
						
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
