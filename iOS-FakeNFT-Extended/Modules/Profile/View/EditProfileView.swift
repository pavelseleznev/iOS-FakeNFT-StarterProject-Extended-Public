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
                            isPhotoActionsPresented: $viewModel.isPhotoActionsPresented,
							avatarURLString: viewModel.avatarURL,
                            didTapChangePhoto: { viewModel.changePhotoTapped() },
                            didTapDeletePhoto: { viewModel.deletePhotoTapped() }
                        )
                        
                        EditProfileForm(
                            name: $viewModel.name,
                            about: $viewModel.about,
                            website: $viewModel.website
                        )
                        
                        Spacer(minLength: 40)
                    }
					.padding(.vertical, 20)
                }
				.scrollContentBackground(.hidden)
				.scrollIndicators(.hidden)
				.scrollDismissesKeyboard(.interactively)
				.contentMargins(.bottom, viewModel.keyboardHeight)
                
                EditProfileFooter(
                    isVisible: viewModel.canSave,
                    onSave: {
                        Task(priority: .userInitiated) {
							await viewModel.performSave()
                        }
                    }
                )
            }
            .edgesIgnoringSafeArea(.bottom)
            .contentShape(Rectangle())
        }
        .applyPhotoURLAlert(
            isPresented: $viewModel.isPhotoURLAlertPresented,
            photoURL: $viewModel.photoURLInput,
            onSave: viewModel.savePhotoURLString
        )
        .applyRepeatableAlert(
            isPresented: $viewModel.isSaveErrorPresented,
            message: viewModel.saveErrorMessage,
            didTapRepeat: {
                Task(priority: .userInitiated) {
					await viewModel.performSave()
                }
            }
        )
        .overlay {
            LoadingView(loadingState: viewModel.loadingState)
        }
		.onReceive(
			NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification),
			perform: viewModel.keyboardWillChangeFrame
		)
		.toolbar {
			ToolbarItem(placement: .title) {
                Text(viewModel.editProfileTitle)
					.font(.bold17)
					.foregroundStyle(.ypBlack)
			}
		}
    }
}
