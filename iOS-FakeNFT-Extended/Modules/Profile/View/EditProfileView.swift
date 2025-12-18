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
    
    @State private var viewModel: EditProfileViewModel
    @FocusState private var focusedField: EditProfileField?

    init(
        profile: ProfileModel,
        onSave: @escaping (ProfileModel) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: EditProfileViewModel(profile: profile))
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            ZStack {
                VStack(spacing: 0) {
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
                }
                
                EditProfileFooter(
                    isVisible: viewModel.canSave,
                    onSave: {
                        Task {
                            do {
                                let updatedProfile = try await viewModel.saveTapped()
                                onSave(updatedProfile)
                            } catch {
                                // TODO: Handle error (alert, log, etc.)
                                print(error)
                            }
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
        .overlay {
            LoadingView(loadingState: viewModel.loadingState)
        }
    }
}

struct EditProfileView_Preview: PreviewProvider {
    static var mockProvider = MockProfileProvider()
    
    static var previews: some View {
        let sampleProfile = mockProvider.profile()
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
