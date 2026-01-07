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
	let rating: String
	
	private let imageSize: CGFloat = 70
	
	init(name: String, imageURLString: String, about: String, rating: String = "") {
		self.name = name
		self.imageURLString = imageURLString
		self.about = about
		self.rating = rating
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			HStack(spacing: 16) {
				AsyncImageCached(urlString: imageURLString) { phase in
					switch phase {
					case .empty:
						Color.ypLightGrey
							.overlay {
								ProgressView()
							}
					case .loaded(let image):
						Image(uiImage: image)
							.resizable()
							.scaledToFit()
					case .error:
						Image.profilePerson
							.resizable()
							.renderingMode(.template)
							.foregroundStyle(.ypGrayUniversal)
							.aspectRatio(contentMode: .fit)
					}
				}
				.frame(width: imageSize, height: imageSize)
				.clipShape(.circle)
				
				VStack(alignment: .leading, spacing: 4) {
					Text(name)
						.foregroundStyle(.ypBlack)
						.font(.bold22)
					if !rating.isEmpty {
						RatingPreview(rating: Int(rating) ?? 0)
							.scaleEffect(1.3, anchor: .leading)
							.frame(height: 24)
					}
				}
				
				Spacer()
			}
			
			Group {
				if about.isEmpty {
					Text(.noDescription)
				} else {
					Text(about)
				}
			}
			.lineSpacing(4)
			.foregroundStyle(.ypBlack)
			.font(.regular13)
		}
		.padding(.horizontal, 16)
	}
}
