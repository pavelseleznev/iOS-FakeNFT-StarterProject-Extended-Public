//
//  ProfileHeader.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct ProfileHeader: View {
	let name: String
	let image: Image
	let about: String
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			HStack(spacing: 16) {
				image
					.resizable()
					.scaledToFit()
					.frame(width: 70)
				Text(name)
					.foregroundStyle(.ypBlack)
					.font(.bold22)
				
				Spacer()
			}
			
			Text(about)
				.lineSpacing(4)
				.foregroundStyle(.ypBlack)
				.font(.regular13)
		}
		.padding(.horizontal, 16)
	}
}
