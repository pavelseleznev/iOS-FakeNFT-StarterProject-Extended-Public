//
//  EditProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

struct EditProfileView: View {
    let onCancel: () -> Void
    
    @State private var viewModel: EditProfileViewModel
    @FocusState private var focusedField: EditProfileField?

    init(
		profile: ProfilePayload,
        profileService: ProfileServiceProtocol,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: EditProfileViewModel(
            profile: profile,
            profileService: profileService)
        )
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
				.scrollContentBackground(.hidden)
				.scrollDismissesKeyboard(.immediately)
                
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
//            message: viewModel.saveErrorMessage, // TODO: Localize
			message: .cancel,
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
			onCancel()
        } catch {
            guard !(error is CancellationError) else { return }
            print("Save profile failed:", error)
            viewModel.isSaveErrorPresented = true
        }
    }
}
