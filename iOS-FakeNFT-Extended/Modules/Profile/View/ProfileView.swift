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
        profile: ProfileModel,
        router: ProfileRouting,
        service: ProfileService,
        myNFTStore: MyNFTViewModel,
        favoriteNFTStore: FavoriteNFTViewModel,
        profileStore: ProfileStore,
        api: ObservedNetworkClient
    ) {
        _viewModel = State(
            initialValue: ProfileViewModel(
                profile: profile,
                router: router,
                service: service,
                myNFTStore: myNFTStore,
                favoriteNFTStore: favoriteNFTStore,
                profileStore: profileStore,
                api: api
            ))
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
        .task {
            await viewModel.load()
        }
        .applyRepeatableAlert(
            isPresented: $viewModel.loadErrorPresented,
            message: viewModel.loadErrorMessage) {
                Task { await viewModel.retryLoad() }
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
