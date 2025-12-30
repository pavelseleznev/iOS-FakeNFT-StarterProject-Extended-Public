//
//  Coordinator.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

@Observable
@MainActor
final class Coordinator {
	let appContainer: AppContainer
	var path = NavigationPath()
	var sheet: Sheet?
	var fullScreencover: FullScreenCover? = .splash
	
	init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}
}

// MARK: - Coordinator Extensions

// --- internal navigation ---
extension Coordinator {
	func push(_ page: Page) {
		path.append(page)
	}
	
	func pop() {
        guard !path.isEmpty else { return }
		path.removeLast()
	}
}

// --- internal sheet managment ---
extension Coordinator {
	func present(_ sheet: Sheet) {
		self.sheet = sheet
	}
	
	func dismissSheet() {
		self.sheet = nil
	}
	
	func present(_ fullScreenCover: FullScreenCover) {
		self.fullScreencover = fullScreenCover
	}
	
	func dismissFullScreenCover() {
		self.fullScreencover = nil
	}
}

// --- internal view builders ---
extension Coordinator {
    @ViewBuilder
    func build(_ page: Page) -> some View {
        switch page {
        case .tabView:
            TabBarView(
                appContainer: appContainer,
                push: push,
                present: present,
                dismiss: dismissSheet,
                pop: pop
            )
            
        case let .aboutAuthor(urlString):
            AboutAuthorView(websiteURLString: urlString)
        case .statNFTCollection(nfts: let nfts):
            EmptyView()
        case .statProfile(profile: let profile):
            EmptyView()
        case .editProfile(let profile):
            EditProfileView(
                profile: profile,
                profileStore: appContainer.profileStore,
                onSave: { _ in
                    Task { @MainActor in
                        self.pop()
                    }
                },
                onCancel: {
                    Task { @MainActor in
                        self.pop()
                    }
                }
            )
        case .myNFTs:
            MyNFTView(viewModel: appContainer.myNFTStore)
        case .favoriteNFTs:
            FavoriteNFTView(viewModel: appContainer.favoriteNFTStore)
        }
    }
	
	@ViewBuilder
	func build(_ sheet: Sheet) -> some View {
		switch sheet {
		case let .nftDetail(nft):
			NFTDetailView(nft: nft)
		}
	}
	
	@ViewBuilder
	func build(_ fullScreenCover: FullScreenCover) -> some View {
		switch fullScreenCover {
		case .splash:
			SplashView()
		}
	}
}
