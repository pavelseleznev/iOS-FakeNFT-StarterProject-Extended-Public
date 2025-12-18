//
//  NFTButtonStyle.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

private struct NFTButtonStyle: ButtonStyle {
	let filled: Bool
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(10)
			.font(.regular15)
			.foregroundStyle(filled ? .ypWhite : .ypWhiteUniversal)
			.frame(maxWidth: .infinity)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(filled ? Color.ypBlack : Color.clear)
					.stroke(Color.ypBlack, lineWidth: 1)
			)
			.opacity(configuration.isPressed ? 0.5 : 1)
			.padding(.top, 16)
	}
}

extension View {
	func nftButtonStyle(filled: Bool = false) -> some View {
		self
			.buttonStyle(NFTButtonStyle(filled: filled))
	}
}


#if DEBUG
#Preview {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		VStack {
			Button(action: {}) {
				Text("Hello World!")
			}
			.nftButtonStyle()
			
			Button(action: {}) {
				Text("Hello World!")
			}
			.nftButtonStyle(filled: true)
		}
		.padding(.horizontal)
	}
}
#endif
