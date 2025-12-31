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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                Group {
                    let trimmed = imageURLString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let url = URL(string: trimmed),
                       ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                userPicturePlaceholder
                                    .overlay {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                userPicturePlaceholder
                            @unknown default:
                                userPicturePlaceholder
                            }
                        }
                    } else {
                        userPicturePlaceholder
                    }
                }
                .clipShape(Circle())
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
    
    private var userPicturePlaceholder: some View {
        Image.userPicturePlaceholder
            .resizable()
            .scaledToFit()
    }
}
