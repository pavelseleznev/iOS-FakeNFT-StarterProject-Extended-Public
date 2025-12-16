//
//  EditProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

struct EditProfileView: View {
    
    let onSave: (ProfileModel) -> Void
    let onCancel: () -> Void
    
    @State private var name: String
    @State private var about: String
    @State private var website: String
    @State private var showExitAlert = false
    @State private var isPhotoActionsPresented = false
    @State private var isPhotoURLAlertPresented = false
    @State private var photoURLInput = ""
    @State private var loadingState: LoadingState = .idle
    @FocusState private var focusedField: Field?
    
    private let avatarURL: String
    private let originalProfile: ProfileModel
    private var isTextFieldValid: Bool {!name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty}
    
    private var isModified: Bool {
        let nameNonEmpty = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let aboutNonEmpty = !about.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let websiteNonEmpty = !website.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let anyFieldChanged =
        name != originalProfile.name ||
        about != originalProfile.about ||
        website != originalProfile.website
        return nameNonEmpty && aboutNonEmpty && websiteNonEmpty && anyFieldChanged
    }
    
    private var hasUnsavedChanges: Bool {
        name != originalProfile.name ||
        about != originalProfile.about ||
        website != originalProfile.website
    }
    
    init(
        profile: ProfileModel,
        onSave: @escaping (ProfileModel) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _name = State(initialValue: profile.name)
        _about = State(initialValue: profile.about)
        _website = State(initialValue: profile.website)
        avatarURL = profile.avatarURL
        originalProfile = profile
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    // TODO: Implement photo change functionality
    private func handleChangePhoto() {
        isPhotoActionsPresented = false
        isPhotoURLAlertPresented = true
    }
    // TODO: Implement photo deletion functionality
    private func handleDeletePhoto() {}
    
    private func performSave() {
        loadingState = .fetching
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let profile = ProfileModel(
                name: name,
                about: about,
                website: website,
                avatarURL: avatarURL
            )
            onSave(profile)
            loadingState = .idle
        }
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            EditProfileHeader(
                                avatarURL: avatarURL,
                                isPhotoActionsPresented: $isPhotoActionsPresented,
                                didTapChangePhoto: handleChangePhoto,
                                didTapDeletePhoto: handleDeletePhoto
                            )
                            
                            EditProfileForm(
                                name: $name,
                                about: $about,
                                website: $website,
                                focusedField: _focusedField
                            )
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                EditProfileFooter(
                    isVisible: isModified,
                    onSave: {
                        performSave()
                    }
                )
            }
            .edgesIgnoringSafeArea(.bottom)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = nil }
            .dismissGuard(
                hasUnsavedChanges: hasUnsavedChanges,
                showAlert: $showExitAlert,
                onConfirmDismiss: { onCancel() }
            )
        }
        .applyPhotoURLAlert(
            isPresented: $isPhotoURLAlertPresented,
            photoURL: $photoURLInput,
            onSave: { url in },
            onCancel: {}
        )
        .overlay {
            LoadingView(loadingState: loadingState)
        }
    }
}

struct EditProfileView_Preview: PreviewProvider {
    static var sampleProfile: ProfileModel {
        .init(
            name: "Joaquin Phoenix",
            about: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.",
            website: "Joaquin Phoenix.com",
            avatarURL: "userPickMockEdit"
        )
    }
    
    static var previews: some View {
            Group {
                EditProfileView(
                    profile: sampleProfile,
                    onSave: { newProfile in print("Saved: \(newProfile)")
                    },
                    onCancel: {
                        print("Cancelled")
                    }
                )
                .previewDisplayName("Light")
                .environment(\.colorScheme, .light)
                
                EditProfileView(
                    profile: sampleProfile,
                    onSave: { _ in },
                    onCancel: {}
                )
                .previewDisplayName("Dark")
                .environment(\.colorScheme, .dark)
            }
        }
}
