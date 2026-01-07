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
	
	@State private var name = ""
	@State private var description = ""
	@State private var avatarURLString = ""
	@State private var websiteURLString = ""
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			VStack(alignment: .leading, spacing: 24) {
				AsyncImageCached(urlString: avatarURLString) { phase in
					switch phase {
					case .empty:
						ProgressView()
					case .loaded(let uIImage):
						Image(uiImage: uIImage)
							.resizable()
							.scaledToFit()
							.frame(width: 100, height: 100)
					case .error:
						Text("?")
							.font(.bold22)
							.foregroundStyle(.ypBlack)
					}
				}
				
				Text(name)
					.font(.bold22)
					.foregroundStyle(.ypBlack)
				
				Text(description)
					.font(.regular15)
					.foregroundStyle(.ypBlack)
				
				Text(websiteURLString)
					.font(.regular15)
					.foregroundStyle(.ypBlack)
			}
		}
		.safeAreaInset(edge: .top) {
			HStack {
				Spacer()
				Button {} label: {
					Image.edit
						.foregroundStyle(.ypBlack)
						.font(.editProfileIcon)
				}
				.padding(.trailing, 8)
			}
		}
		.toolbar(.hidden)
		.task {
			let profile = await appContainer.profileService.get()
			name = profile.name ?? ""
			description = profile.description ?? ""
			avatarURLString = profile.avatar ?? ""
			websiteURLString = profile.website ?? ""
		}
		.onReceive(NotificationCenter.default.publisher(for: .profileNameDidChange)) { notification in
			guard let newName = notification.userInfo?[ProfileStorageKey.name.key] as? String else { return }
			name = newName
		}
	}
}
