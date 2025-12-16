//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct ProfileView: View {
	let appContainer: AppContainer
	let push: (Page) -> Void
    private let profileURLString = "https://example.com"
    private var mockProfile: ProfileModel {
        .init(
            name: "Joaquin Phoenix",
            about: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.",
            website: "Joaquin Phoenix.com",
            avatarURL: "userPickMockEdit"
        )
    }
    
	var body: some View {
		ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            ProfileContainer(
                name: "Joaquin Phoenix",
                imageURLString: "userPickMock",
                about: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям."
            ) {
                Button { push(.aboutAuthor(urlString: profileURLString)) } label: {
                    Text("Joaquin Phoenix.com")
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
			HStack {
				Spacer()
				Button {
					push(.editProfile(mockProfile))
				} label: {
					Image.edit
						.foregroundStyle(.ypBlack)
						.font(.editProfileIcon)
				}
				.padding(.trailing, 8)
			}
		}
	}
}
