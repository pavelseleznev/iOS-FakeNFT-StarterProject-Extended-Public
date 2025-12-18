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
                    if let url = URL(string: avatarURL),
                       let scheme = url.scheme,
                       (scheme == "http" || scheme == "https") {
                        KFImage(url)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(avatarURL)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 70)
                .onTapGesture { isPhotoActionsPresented = true }
                .modifier(ProfilePhotoActionsViewModifier(
                    isPresented: $isPhotoActionsPresented,
                    didTapChangePhoto: didTapChangePhoto,
                    didTapDeletePhoto: didTapDeletePhoto
                ))
            }
        }
    }
}
