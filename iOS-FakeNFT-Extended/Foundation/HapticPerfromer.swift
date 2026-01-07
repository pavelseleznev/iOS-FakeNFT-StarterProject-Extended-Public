//
//  HapticPerfromer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 07.01.2026.
//

import UIKit
import CoreHaptics

@MainActor
final class HapticPerfromer {
	static let shared = HapticPerfromer()
	
	private var engine: CHHapticEngine?
	
	private let selectionGenerator = UISelectionFeedbackGenerator()
	private let notificationGenerator = UINotificationFeedbackGenerator()
	
	private init() {
		prepareCoreHaptics()
	}
	
	enum Style {
		case impact(UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1)
		case notification(UINotificationFeedbackGenerator.FeedbackType)
		case selection
		case splashWave
	}
	
	func play(_ style: Style) {
		switch style {
		case .impact(let impactStyle, let intensity):
			impact(impactStyle, intensity: intensity)
			
		case .notification(let notificationStyle):
			notify(notificationStyle)
			
		case .selection:
			selectionGenerator.prepare()
			selectionGenerator.selectionChanged()
			
		case .splashWave:
			playSplashPattern()
		}
	}
}

// MARK: - HapticPerfromer Extensions
// --- base ---
private extension HapticPerfromer {
	private func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
		notificationGenerator.prepare()
		notificationGenerator.notificationOccurred(type)
	}
	
	private func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
		let generator = UIImpactFeedbackGenerator(style: style)
		generator.prepare()
		generator.impactOccurred(intensity: intensity)
	}
}

// --- custom ---
private extension HapticPerfromer {
	private func prepareCoreHaptics() {
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
		
		do {
			engine = try CHHapticEngine()
			try engine?.start()
			
			engine?.resetHandler = { [weak self] in
				try? self?.engine?.start()
			}
		} catch {
			print("Haptic engine error: \(error.localizedDescription)")
		}
	}
	
	private func playSplashPattern() {
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
		
		var events = [CHHapticEvent]()
		
		for i in stride(from: 0, to: 1, by: 0.1) {
			let intensity = CHHapticEventParameter(
				parameterID: .hapticIntensity,
				value: Float(i)
			)
			let sharpness = CHHapticEventParameter(
				parameterID: .hapticSharpness,
				value: 0.5
			)
			
			let event = CHHapticEvent(
				eventType: .hapticTransient,
				parameters: [intensity, sharpness],
				relativeTime: TimeInterval(i * 0.4)
			)
			
			events.append(event)
		}
		
		let finalHit = CHHapticEvent(
			eventType: .hapticTransient,
			parameters: [
				.init(parameterID: .hapticIntensity, value: 1),
				.init(parameterID: .hapticSharpness, value: 1),
			],
			relativeTime: TimeInterval(Constants.splashPresentationDuration.components.seconds)
		)
		
		events.append(finalHit)
		
		do {
			let pattern = try CHHapticPattern(events: events, parameters: [])
			let player = try engine?.makePlayer(with: pattern)
			try player?.start(atTime: 0)
		} catch {
			print("Failed to play splashWave: \(error.localizedDescription)")
		}
	}
}

#if DEBUG
// MARK: - Preview on physical device
import SwiftUI

struct MyView: View {
	var body: some View {
		ScrollView(.vertical) {
			VStack {
				Button {
					HapticPerfromer.shared.play(.impact(.light))
				} label: {
					Text("light")
						.font(.bold32)
				}
				
				// like/cart
				Button {
					HapticPerfromer.shared.play(.impact(.medium))
				} label: {
					Text("medium")
						.font(.bold32)
				}
				
				Button {
					HapticPerfromer.shared.play(.impact(.heavy))
				} label: {
					Text("heavy")
						.font(.bold32)
				}
				
				// overscroll state changed
				Button {
					HapticPerfromer.shared.play(.impact(.soft))
				} label: {
					Text("soft")
						.font(.bold32)
				}
				
				Button {
					HapticPerfromer.shared.play(.impact(.rigid))
				} label: {
					Text("rigid")
						.font(.bold32)
				}
				
				Button {
					HapticPerfromer.shared.play(.selection)
				} label: {
					Text("selection")
						.font(.bold32)
				}
				
				Button {
					HapticPerfromer.shared.play(.notification(.error))
				} label: {
					Text("error")
						.font(.bold32)
				}
				
				Button {
					HapticPerfromer.shared.play(.notification(.success))
				} label: {
					Text("success")
						.font(.bold32)
				}
				
				Button {
					HapticPerfromer.shared.play(.notification(.warning))
				} label: {
					Text("warning")
						.font(.bold32)
				}
			}
		}
	}
}

#Preview {
	MyView()
}
#endif
