//
//  EditProfileHeader.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

struct EditProfileHeader: View {
    @Binding var avatarURL: String
    @Binding var isPhotoActionsPresented: Bool
    let didTapChangePhoto: () -> Void
    let didTapDeletePhoto: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(
                url: URL(
                    string: avatarURL.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            ) { phase in
                switch phase {
                case .empty:
                    placeholder
                        .overlay {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .onTapGesture {
                isPhotoActionsPresented = true
            }
            .modifier(
                ProfilePhotoActionsViewModifier(
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
    private var placeholder: some View {
        Image.userPicturePlaceholder
            .resizable()
            .scaledToFit()
    }
}
