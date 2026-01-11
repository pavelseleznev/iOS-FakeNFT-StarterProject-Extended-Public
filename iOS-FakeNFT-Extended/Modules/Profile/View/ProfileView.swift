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
		profileService: ProfileServiceProtocol,
		favouritesService: NFTsIDsServiceProtocol,
		purchaseService: NFTsIDsServiceProtocol,
        push: @escaping (Page) -> Void,
    ) {
		_viewModel = State(
			initialValue: ProfileViewModel(
				profileService: profileService,
				favouritesService: favouritesService,
				purchaseService: purchaseService,
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
							caption: "\(viewModel.purchasedIDs.count)",
							title: .myNFTs,
							action: viewModel.myNFTsTapped
						),
						ProfileActionCell(
							caption: "\(viewModel.favoutiresIDs.count)",
							title: .favouritedNFTs,
							action: viewModel.favoriteNFTsTapped
						)
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
