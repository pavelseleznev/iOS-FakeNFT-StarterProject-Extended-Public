//
//  ProfileActionCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct ProfileActionCell: View, Identifiable {
	let title: LocalizedStringResource
	let action: () -> Void
	
	let id = UUID().uuidString
	
	var body: some View {
		Button {
			HapticPerfromer.shared.play(.impact(.light))
			action()
		} label: {
			HStack {
				Text(title)
					.font(.bold17)
				Spacer()
				Image.chevronRight
					.font(.chevronRightIcon)
			}
			.foregroundStyle(.ypBlack)
		}
		.padding(16)
	}
}
