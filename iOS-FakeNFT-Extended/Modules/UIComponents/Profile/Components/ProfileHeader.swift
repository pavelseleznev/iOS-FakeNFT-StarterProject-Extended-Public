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
                AsyncImage(
                    url: URL(string: imageURLString.trimmingCharacters(in: .whitespacesAndNewlines))
                ) { phase in
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
