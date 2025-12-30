//
//  EditProfileHeader.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI
import Kingfisher

struct EditProfileHeader: View {
    @Binding var avatarURL: String
    @Binding var isPhotoActionsPresented: Bool
    let didTapChangePhoto: () -> Void
    let didTapDeletePhoto: () -> Void

    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Group {
                    let trimmed = avatarURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let url = URL(string: trimmed),
                       ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                        KFImage(url)
                            .placeholder {
                                Image.userPicturePlaceholder
                                    .resizable()
                                    .scaledToFit()
                            }
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image.userPicturePlaceholder
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .onTapGesture { isPhotoActionsPresented = true }
            .modifier(ProfilePhotoActionsViewModifier(
                isPresented: $isPhotoActionsPresented,
                didTapChangePhoto: didTapChangePhoto,
                didTapDeletePhoto: didTapDeletePhoto
            ))
            
            Image.frameCamera
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .offset(x: 4, y: 4)
        }
    }
}
