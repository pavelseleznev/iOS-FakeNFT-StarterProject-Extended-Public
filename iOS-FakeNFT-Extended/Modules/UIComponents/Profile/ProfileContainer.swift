//
//  ProfileContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct ProfileContainer<Link: View>: View {
	let name: String
	let image: Image
	let about: String
	
	let link: () -> Link
	let actions: () -> [ProfileActionCell]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 40) {
			VStack(alignment: .leading, spacing: 8) {
				ProfileHeader(
					name: name,
					image: image,
					about: about
				)
				
				link()
					.font(.regular15)
					.padding(.horizontal, 16)
			}
			
			VStack {
				ForEach(actions()) { action in
					action
				}
			}
			
			Spacer()
		}
	}
}

#if DEBUG
#Preview("My profile") {
	NavigationStack {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			ProfileContainer(
				name: "Joaquin Phoenix",
				image: Image(.userPickMock),
				about: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям."
			) {
				Link("Joaquin Phienix.com", destination: .init(string: "https://google.com")!)
			} actions: {
				[
					ProfileActionCell(title: "Мои NFT (112)", action: {}),
					ProfileActionCell(title: "Избранные NFT (11)", action: {})
				]
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(action: {}) {
						Image.edit
							.foregroundStyle(.ypBlack)
							.font(.editProfileIcon)
					}
				}
			}
		}
	}
}

#Preview("Other any profile") {
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		
		ProfileContainer(
			name: "Joaquin Phoenix",
			image: Image(.userPickMock),
			about: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям."
		) {
			Button(action: {}) {
				Text("Перейти на сайт пользователя")
			}
			.nftButtonStyle()
		} actions: {
			[
				ProfileActionCell(title: "Коллекция NFT (112)", action: {})
			]
		}
	}
}
#endif
