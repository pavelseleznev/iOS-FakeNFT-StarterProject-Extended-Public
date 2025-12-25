//
//  ProfileHeader.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct ProfileHeader: View {
	let name: String
	let imageURLString: String
	let about: String
	
	private let imageSize: CGFloat = 70
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			HStack(spacing: 16) {
				Group {
					AsyncImage(
						url: URL(string: imageURLString),
						transaction: .init(animation: .easeInOut(duration: 0.15))
					) { phase in
						switch phase {
						case .empty:
							ProgressView()
								.progressViewStyle(.circular)
						case .success(let image):
							image
								.resizable()
								.scaledToFit()
						default:
							Image.profilePerson
								.resizable()
								.scaledToFit()
						}
					}
				}
				.clipShape(Circle())
				.frame(width: imageSize, height: imageSize)
				
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
