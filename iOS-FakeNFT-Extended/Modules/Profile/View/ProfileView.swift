//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    init(
        appContainer: AppContainer,
        push: @escaping (Page) -> Void,
        myNFTStore: MyNFTViewModel,
        favoriteNFTStore: FavoriteNFTViewModel
    ) {
        _viewModel = State(
            initialValue: ProfileViewModel(
                appContainer: appContainer,
                myNFTStore: myNFTStore,
                favoriteNFTStore: favoriteNFTStore,
                push: push
                )
            )
    }
    
	var body: some View {
		ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            ProfileContainer(
                name: viewModel.profile.name,
                imageURLString: viewModel.profile.avatarURL,
                about: viewModel.profile.about
            ) {
                Button { viewModel.websiteTapped()
                } label: {
                    Text(viewModel.profile.website)
                }
            } actions: {
                [
                    ProfileActionCell(
                        title: viewModel.myNFTTitle,
                        action: {
                            viewModel.myNFTsTapped()
                        }
                    ),
                    ProfileActionCell(
                        title: viewModel.favoriteTitle,
                        action: {
                            viewModel.favoriteNFTsTapped()
                        })
                ]
            }

		}
		.safeAreaInset(edge: .top) {
			editButton
		}
        .task(priority: .userInitiated) { await viewModel.load() }
        .applyRepeatableAlert(
            isPresented: $viewModel.loadErrorPresented,
            message: viewModel.loadErrorMessage
        ) {
            Task(priority: .userInitiated) {
                await viewModel.retryLoad()
            }
        }
	}
}

private extension ProfileView {
    var editButton: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.editTapped()
            } label: {
                Image.edit
                    .foregroundStyle(.ypBlack)
                    .font(.editProfileIcon)
            }
            .padding(.trailing, 8)
        }
    }
}
