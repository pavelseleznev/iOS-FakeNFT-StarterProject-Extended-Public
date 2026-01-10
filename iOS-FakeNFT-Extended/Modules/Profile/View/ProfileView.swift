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
		service: ProfileServiceProtocol,
        push: @escaping (Page) -> Void,
    ) {
		_viewModel = State(
			initialValue: ProfileViewModel(
				service: service,
				push: push
			)
		)
	}
    
	var body: some View {
		ZStack {
            Color.ypWhite.ignoresSafeArea()
            
			ProfileContainer(
				model: .init(from: viewModel.profile),
				link: {
					Button(.goToUserSite, action: viewModel.websiteTapped)
						.nftButtonStyle(filled: false)
				}, actions: {
					[
						ProfileActionCell(
							caption: "\(viewModel.profile.nftsIDs?.count ?? -1)",
							title: .myNFTs,
							action: {
								viewModel.myNFTsTapped()
							}
						),
						ProfileActionCell(
							caption: "\(viewModel.profile.favoritesIDs?.count ?? -1)",
							title: .favouritedNFTs,
							action: {
								viewModel.favoriteNFTsTapped()
							})
					]
				}
			)
		}
		.safeAreaInset(edge: .top) {
			editButton
		}
        .task(priority: .userInitiated) {
			await viewModel.load()
        }
		.onReceive(
			NotificationCenter.default.publisher(for: .profileDidUpdate),
			perform: viewModel.profileDidUpdate
		)
	}
}

private extension ProfileView {
    var editButton: some View {
        HStack {
            Spacer()
            
            Button {
				guard !viewModel.profile.anyFieldDidntLoaded else { return }
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
