//
//  EditProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

struct EditProfileView: View {
    
    let onSave: @Sendable (ProfileModel) -> Void
    let onCancel: () -> Void
    
    @State private var viewModel: EditProfileViewModel
    @FocusState private var focusedField: EditProfileField?

    init(
        profile: ProfileModel,
        profileStore: ProfileStore,
        onSave: @Sendable @escaping (ProfileModel) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: EditProfileViewModel(
            profile: profile,
            profileStore: profileStore)
        )
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        EditProfileHeader(
                            avatarURL: $viewModel.avatarURL,
                            isPhotoActionsPresented: $viewModel.isPhotoActionsPresented,
                            didTapChangePhoto: { viewModel.changePhotoTapped() },
                            didTapDeletePhoto: { viewModel.deletePhotoTapped() }
                        )
                        
                        EditProfileForm(
                            name: $viewModel.name,
                            about: $viewModel.about,
                            website: $viewModel.website,
                            focusedField: _focusedField
                        )
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
                
                EditProfileFooter(
                    isVisible: viewModel.canSave,
                    onSave: {
                        Task(priority: .userInitiated) {
                            await performSave()
                        }
                    }
                )
            }
            .edgesIgnoringSafeArea(.bottom)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = nil }
            .dismissGuard(
                hasUnsavedChanges: viewModel.hasUnsavedChanges,
                showAlert: $viewModel.showExitAlert,
                onConfirmDismiss: { onCancel() }
            )
        }
        .applyPhotoURLAlert(
            isPresented: $viewModel.isPhotoURLAlertPresented,
            photoURL: $viewModel.photoURLInput,
            onSave: { url in
                viewModel.photoURLSaved(url)
            },
            onCancel: {
                viewModel.photoURLCancelled()
            }
        )
        .applyRepeatableAlert(
            isPresented: $viewModel.isSaveErrorPresented,
            message: viewModel.saveErrorMessage,
            didTapRepeat: {
                Task(priority: .userInitiated) {
                    await performSave()
                }
            }
        )
        .overlay {
            LoadingView(loadingState: viewModel.loadingState)
        }
    }
    
    @MainActor
    private func performSave() async {
        do {
            try await viewModel.saveTapped()
            onSave(ProfileModel(
                name: viewModel.name,
                about: viewModel.about,
                website: viewModel.website,
                avatarURL: viewModel.avatarURL
            ))
        } catch {
            viewModel.isSaveErrorPresented = true
        }
    }
}

struct EditProfileView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            EditProfileView(
                profile: .preview,
                profileStore: .preview,
                onSave: { _ in },
                onCancel: {}
            )
            .previewDisplayName("Light")
            .environment(\.colorScheme, .light)
            
            EditProfileView(
                profile: .preview,
                profileStore: ProfileStore.preview,
                onSave: { _ in },
                onCancel: {}
            )
            .previewDisplayName("Dark")
            .environment(\.colorScheme, .dark)
        }
    }
}
