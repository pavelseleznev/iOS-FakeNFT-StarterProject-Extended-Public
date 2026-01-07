//
//  BlinkingAppIcon.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.01.2026.
//

import SwiftUI
import Combine

fileprivate enum BlinkPhase {
	case start(Direction)
	case peak(Direction)
	case end(Direction)
	
	enum Direction {
		case forward, reverse
	}
	
	var offset: CGFloat {
		switch self {
		case .start:
			0
		case .peak:
			1
		case .end:
			2
		}
	}
	
	var rotationRatio: CGFloat {
		switch self {
		case .start:
			-1
		case .peak:
			0
		case .end:
			1
		}
	}
	
	var next: Self {
		switch self {
		case .start:
			.peak(.forward)
		case .peak(let direction):
			switch direction {
			case .forward:
				.end(.reverse)
			case .reverse:
				.start(.reverse)
			}
		case .end:
			.peak(.reverse)
		}
	}
}

struct BlinkingAppIcon: View {
	let imageSize: CGFloat
	
	@State private var blinkPhase: BlinkPhase = .peak(.forward)
	@State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@State private var isAppeared = false
	
	var body: some View {
		imageView
			.overlay (
				ShimmerOverlay(phase: blinkPhase.offset, width: imageSize)
			)
			.mask(imageView)
			.rotation3DEffect(
				.degrees(10 * blinkPhase.rotationRatio),
				axis: (x: 1, y: -1, z: -1)
			)
			.onAppear {
				withAnimation(
					.spring(response: 0.4, dampingFraction: 0.3, blendDuration: 0.1)
				) {
					isAppeared = true
				}
			}
			.onReceive(timer, perform: performBlink)
			.scaleEffect(isAppeared ? 1 : 0)
	}
	
	private var imageView: some View {
		Image(.appIconSmall)
			.resizable()
			.scaledToFit()
			.frame(height: imageSize)
	}
	
	private func performBlink(_: Timer.TimerPublisher.Output) {
		let nextPhase = blinkPhase.next
		withAnimation(.linear(duration: 1)) {
			blinkPhase = nextPhase
		}
	}
}

#Preview {
	BlinkingAppIcon(imageSize: 120)
}

fileprivate struct ShimmerOverlay: View {
	let phase: CGFloat
	let width: CGFloat
	
	var body: some View {
		let shimmer = Rectangle()
			.fill(
				LinearGradient(
					gradient: Gradient(colors: [
						.clear,
						Color.white.opacity(0.4),
						.clear
					]),
					startPoint: .leading,
					endPoint: .trailing
				)
			)
			.rotationEffect(.degrees(45))
			.scaleEffect(1.2)
			.offset(
				x: width * phase - width,
				y: width * phase - width
			)
		
		shimmer
			.blendMode(.screen)
	}
}
