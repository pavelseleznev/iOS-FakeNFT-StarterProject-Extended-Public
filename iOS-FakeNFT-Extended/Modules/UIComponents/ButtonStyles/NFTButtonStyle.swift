//
//  NFTButtonStyle.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

private struct NFTButtonStyle: ButtonStyle {
	let filled: Bool
	
	@Environment(\.isEnabled) private var isEnabled: Bool
	@Environment(\.colorScheme) private var theme
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(10)
			.font(.regular15)
			.foregroundStyle(filled ? .ypWhite : .ypBlack)
			.frame(maxWidth: .infinity)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(filled ? Color.ypBlack : Color.clear)
					.stroke(Color.ypBlack, lineWidth: 1)
					.stroke(
						LinearGradient(
							stops: [
								.init(color: .teal, location: 0),
								.init(color: .clear, location: 0.3),
								.init(color: .clear, location: 0.5),
								.init(color: .clear, location: 0.7),
								.init(color: .purple, location: 1),
							],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						),
						lineWidth: filled ? 1 : 0.3
					)
			)
			.opacity(configuration.isPressed ? 0.5 : 1)
			.brightness(brightness)
			.padding(.top, 16)
	}
	
	private var brightness: CGFloat {
		switch theme {
		case .dark:
			isEnabled ? 0 : -0.5
		case .light:
			isEnabled ? 0 : 0.5
		@unknown default:
			0
		}
	}
}

// MARK: - View Helpers
extension View {
	func nftButtonStyle(filled: Bool = false) -> some View {
		self
			.buttonStyle(NFTButtonStyle(filled: filled))
	}
}


// MARK: - Preview
#if DEBUG
#Preview {
	
	@Previewable @State var isEnabled = false
	
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		VStack {
			Button(action: {}) {
				Text("Hello World!")
			}
			.nftButtonStyle()
			.disabled(!isEnabled)
			
			Button(action: {}) {
				Text("Hello World!")
			}
			.nftButtonStyle(filled: true)
			.disabled(!isEnabled)
		}
		.padding(.horizontal)
	}
	.onAppear {
		withAnimation(.easeInOut(duration: 0.15).repeatForever().speed(0.5)) {
			isEnabled.toggle()
		}
	}
}
#endif
