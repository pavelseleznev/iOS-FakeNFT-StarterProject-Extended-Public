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
        favoriteStore: FavoriteNFTViewModel) {
        _viewModel = State(
            initialValue: ProfileViewModel(
            profile: profile,
            router: router,
            service: service,
            favoriteStore: favoriteStore
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
                        title: "Мои NFT (3)",
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
        .overlay {
            LoadingView(loadingState: viewModel.loadingState)
        }
        .task {
            await viewModel.load()
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
