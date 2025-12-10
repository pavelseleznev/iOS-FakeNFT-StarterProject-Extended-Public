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
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			Text("Profile")
				.font(.title)
				.bold()
		}
		.safeAreaInset(edge: .top) {
			HStack {
				Spacer()
				Button {
//					push(.aboutAuthor)
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
