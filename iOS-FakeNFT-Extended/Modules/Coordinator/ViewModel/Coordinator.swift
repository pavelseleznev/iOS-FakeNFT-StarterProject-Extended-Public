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
	private let secureStorage = AuthSecureStorage(service: Constants.userDataKeychainService)
	private let appContainer: AppContainer
	private var path = [Page]()
	private var sheet: Sheet?
	private var fullScreenCover: FullScreenCover?
	private var ratingViewIsPresented = false
	
	init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}
	
	let rootPage: Page = {
		if UserDefaults.standard.bool(forKey: Constants.isOnboardingCompleteKey) {
			if UserDefaults.standard.bool(forKey: Constants.isAuthedKey) {
				.splash
			} else {
				.authorization(.login)
			}
		} else {
			.onboarding
		}
	}()
}

// MARK: - Coordinator Extensions
// --- internal bindings ---
extension Coordinator {
	var bindingPath: Binding<[Page]> {
		.init(
			get: { self.path },
			set: { self.updatePath($0) }
		)
	}
	
	var bindingRatingViewIsPresented: Binding<Bool> {
		.init(
			get: { self.ratingViewIsPresented },
			set: { [weak self] in self?.updateRatingViewIsPresented($0) }
		)
	}
	
	var bindingSheet: Binding<Sheet?> {
		.init(
			get: { self.sheet },
			set: { [weak self] in self?.updateSheet($0) }
		)
	}
	
	var bindingsFullScreencover: Binding<FullScreenCover?> {
		.init(
			get: { self.fullScreenCover },
			set: { [weak self] in self?.updateFullScreencover($0) }
		)
	}
}

// --- private updaters ---
private extension Coordinator {
	func updatePath(_ newValue: [Page]) {
		print("Navigation path updated to: \(newValue)")
		var transaction = Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) {
			path = newValue
		}
	}

	func updateRatingViewIsPresented(_ newValue: Bool) {
		print("ratingViewIsPresented is updated to: \(newValue)")
		ratingViewIsPresented = newValue
	}
	
	func updateSheet(_ newValue: Sheet?) {
		print("sheet is updated to: \(String(describing: newValue))")
		sheet = newValue
	}
	
	func updateFullScreencover(_ newValue: FullScreenCover?) {
		print("fullScreenCover is updated to: \(String(describing: newValue))")
		fullScreenCover = newValue
	}
}

// --- private helpers ---
private extension Coordinator {	
	func onLoadingStateFromWebsite(_ state: LoadingState) {
		appContainer.api.setLoadingStateFromWebsite(state)
	}
	
	func onSplashComplete() {
		var transaction = Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) {
			path = [.tabView]
		}
	}
	
	func didTapDetail(
		model: NFTModelContainer,
		authorID: String,
		authorWebsiteURLString: String
	) {
		push(
			.nftDetail(
				model: model,
				authorID: authorID,
				authorWebsiteURLString: authorWebsiteURLString
			)
		)
	}
	
	func onOnboardingComplete() {
		UserDefaults.standard.set(true, forKey: Constants.isOnboardingCompleteKey)
		var transaction = Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) {
			path = [.authorization(.login)]
		}
	}
	
	func performRegistrationFlow() {
		push(.authorization(.reg))
	}
	
	func performForgotPasswordFlow() {
		push(.authorization(.restorePassword))
	}
	
	func onAuthorizationComplete() {
		UserDefaults.standard.set(true, forKey: Constants.isAuthedKey)
		var transaction = Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) {
			path = [.splash]
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
		self.fullScreenCover = fullScreenCover
	}
	
	func dismissFullScreenCover() {
		self.fullScreenCover = nil
	}
}

// --- internal view builders ---
extension Coordinator {
	@ViewBuilder
	func build(_ page: Page) -> some View {
		switch page {
		case .authorization(let page):
			AuthorizationView(
				page: page,
				secureStorage: secureStorage,
				onComplete: onAuthorizationComplete,
				performLoginFlow: pop,
				performRegistrationFlow: performRegistrationFlow,
				performForgotPasswordFlow: performForgotPasswordFlow
			)
			
		case .onboarding:
			OnboardingView(onComplete: onOnboardingComplete)
			
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
				dismiss: dismissSheet
			)
			
		case .aboutAuthor(let websiteURLString):
			AboutAuthorView(
				websiteURLString: websiteURLString,
				onLoadingStateChange: onLoadingStateFromWebsite
			)
			
		case .statNFTCollection(
			let nftsIDs,
			let authorID,
			let authorWebsiteURLString
		):
			StatisticsNFTCollectionView(
				nftsIDs: nftsIDs,
				loadingState: appContainer.api.loadingState,
				nftService: appContainer.nftService,
				didTapDetail: { [weak self] in
					self?.didTapDetail(
						model: $0,
						authorID: authorID,
						authorWebsiteURLString: authorWebsiteURLString
					)
				}
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
			
		case let .nftDetail(nft, authorID, authorWebsiteURLString):
			NFTDetailView(
				model: nft,
				appContainer: appContainer,
				authorID: authorID,
				authorWebsiteURLString: authorWebsiteURLString,
				push: push,
				backAction: pop
			)
		}
	}
	
	@ViewBuilder
	func build(_ sheet: Sheet) -> some View {
		switch sheet {
		case .empty:
			EmptyView()
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
