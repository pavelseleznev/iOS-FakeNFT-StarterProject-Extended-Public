//
//  ProfileActionCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct ProfileActionCell: View, Identifiable {
	let caption: String
	let title: LocalizedStringResource
	let action: () -> Void
	
	let id = UUID().uuidString
	
	@Environment(\.colorScheme) private var theme
	
	var body: some View {
		Button {
			HapticPerfromer.shared.play(.impact(.light))
			action()
		} label: {
			HStack {
				Text(title)
					.font(.bold17)
				Spacer()
				
				HStack(spacing: 8) {
					Text(caption)
						.font(.bold17)
					Image.chevronRight
						.font(.bold22)
				}
			}
			.foregroundStyle(.ypBlack)
			.padding()
			.background(.bar)
			.background(
				LinearGradient(
					colors: [
						.cyan.opacity(theme == .dark ? 0.1 : 1),
						.ypWhite,
						.purple.opacity(theme == .dark ? 0.2 : 1)
					],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
			)
			.clipShape(.capsule)
			.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 7)
		}
		.padding()
	}
}

#Preview {
	Color.ypWhite.ignoresSafeArea()
		.overlay {
			VStack(spacing: -16) {
				ProfileActionCell(caption: "112", title: .nftCollection, action: {})
				ProfileActionCell(caption: "112", title: .nftCollection, action: {})
				ProfileActionCell(caption: "112", title: .nftCollection, action: {})
			}
		}
}
