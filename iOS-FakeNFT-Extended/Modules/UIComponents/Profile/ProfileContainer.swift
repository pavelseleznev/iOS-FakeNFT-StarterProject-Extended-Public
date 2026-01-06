//
//  ProfileContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct ProfileContainer<Link: View>: View {
	let model: UserListItemResponse
	
	let link: () -> Link
	let actions: () -> [ProfileActionCell]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 40) {
			VStack(alignment: .leading, spacing: 8) {
				ProfileHeader(
					name: model.name,
					imageURLString: model.avatarURLString,
					about: model.description ?? "",
					rating: model.rating
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
			
			ProfileContainer(model: .mock) {
				Link("Joaquin Phienix.com", destination: .init(string: "https://google.com")!)
			} actions: {
				[
					ProfileActionCell(
						title: "\(LocalizedStringResource.myNFTs) (112)",
						action: {}
					),
					ProfileActionCell(
						title: "\(LocalizedStringResource.favouritedNFTs) (11)",
						action: {}
					)
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
		
		ProfileContainer(model: .mock) {
			Button(action: {}) {
				Text(.goToUserSite)
			}
			.nftButtonStyle()
		} actions: {
			[
				ProfileActionCell(title: "\(LocalizedStringResource.nftCollection) (112)", action: {})
			]
		}
	}
}
#endif
