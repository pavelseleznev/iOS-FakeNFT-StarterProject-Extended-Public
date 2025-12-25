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
	var path = [Page]()
	var sheet: Sheet?
	var fullScreencover: FullScreenCover?
	
	init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}
}

// MARK: - Coordinator Extensions
// --- private helpers ---
private extension Coordinator {
	func onLoadingStateFromWebsite(_ state: LoadingState) {
		appContainer.api.setLoadingStateFromWebsite(state)
	}
	
	func onSplashComplete() {
		var transaction = Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) {
			push(.tabView)
		}
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
	
	func popToRoot() {
		path.removeLast(path.count - 1)
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
		case .splash:
			SplashView(
				appContainer: appContainer,
				onComplete: onSplashComplete
			)
			
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
			
		case .paymentMethodChoose:
			PaymentMethodChooseView(
				appContainer: appContainer,
				push: push
			)
			
		case .successPayment:
			SuccessPaymentView(backToCart: popToRoot)
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
		case .empty:
			EmptyView()
		}
	}
}
