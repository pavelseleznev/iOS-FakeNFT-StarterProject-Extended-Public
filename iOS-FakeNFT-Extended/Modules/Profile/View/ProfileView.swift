//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    init(profile: ProfileModel, router: ProfileRouting) {
        _viewModel = State(initialValue: ProfileViewModel(
            profile: profile, router: router
        ))
    }
    
	var body: some View {
		ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            ProfileContainer(
                name: "Joaquin Phoenix",
                imageURLString: "userPickMock",
                about: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям."
            ) {
                Button { viewModel.websiteTapped()
                } label: {
                    Text(viewModel.profile.website)
                }
            } actions: {
                [
                    ProfileActionCell(
                        title: "Мои NFT (112)",
                        action: {
                            //TODO: push to "MyNFTs" page
                        }
                    ),
                    ProfileActionCell(
                        title: "Избранные NFT (11)",
                        action: {
                            //TODO: push to "favorites" page
                        })
                ]
            }

		}
		.safeAreaInset(edge: .top) {
			editButton
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
