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
