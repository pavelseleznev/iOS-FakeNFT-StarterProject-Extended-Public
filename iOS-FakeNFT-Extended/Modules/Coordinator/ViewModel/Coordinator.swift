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
	var fullScreenCover: FullScreenCover? = .splash
	    
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
		self.fullScreenCover = fullScreenCover
	}
	
	func dismissFullScreenCover() {
		self.fullScreenCover = nil
	}
}

// --- private helpers ---
private extension Coordinator {
    func onSplashComplete() {
        dismissFullScreenCover()
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
            
        case .splash:
            SplashView(
                appContainer: appContainer,
                onComplete: onSplashComplete
            )
            
        case let .aboutAuthor(urlString):
            AboutAuthorView(websiteURLString: urlString)
        case .statNFTCollection(nfts: let nfts):
            EmptyView()
        case .statProfile(profile: let profile):
            EmptyView()
            
        case .profile(let profilePage):
            switch profilePage {
            case .editProfile(let profile):
                EditProfileView(
                    profile: profile,
                    profileService: appContainer.profileService,
                    onSave: { [weak self] updated in
                        self?.pop()
                    },
                    onCancel: { [weak self] in
                        self?.pop()
                    }
                )
            case .myNFTs:
                MyNFTView(appContainer: appContainer)
                    .customNavigationBackButton(backAction: pop)
            case .favoriteNFTs:
                FavoriteNFTView(appContainer: appContainer)
                    .customNavigationBackButton(backAction: pop)
            }
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
			SplashView(
                appContainer: appContainer,
                onComplete: { [weak self] in
                    self?.dismissFullScreenCover()
                }
            )
		}
	}
}
