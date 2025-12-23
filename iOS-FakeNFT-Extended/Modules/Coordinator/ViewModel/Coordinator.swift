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

// --- internal methods ---
extension Coordinator {
	func loadUserData() async {
		do {
			let profile = try await appContainer.api.getProfile()
			let cart = try await appContainer.api.getOrder()
			
			await appContainer.nftService
				.didLoadUserData(
					likes: profile.likes,
					purchased: profile.nfts,
					cart: cart.nftsIDs
				)
		} catch {
			print(error)
		}
	}
}

// --- private helpers ---
private extension Coordinator {
	func onLoadingStateFromWebsite(_ state: LoadingState) {
		appContainer.api.setLoadingStateFromWebsite(state)
	}
}

// --- internal navigation ---
extension Coordinator {
	func push(_ page: Page) {
		path.append(page)
	}
	
	func pop() {
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
			
		case .aboutAuthor(let websiteURLString):
			AboutAuthorView(
				websiteURLString: websiteURLString,
				onLoadingStateChange: onLoadingStateFromWebsite
			)
			
		case .statNFTCollection(let nftsIDs):
			StatisticsNFTCollectionView(
				nftsIDs: nftsIDs,
				loadingState: appContainer.api.loadingState,
				nftService: appContainer.nftService
			)
			
		case .statProfile(profile: let profile):
			StatisticsProfileView(
				api: appContainer.api,
				push: push,
				model: profile
			)
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
