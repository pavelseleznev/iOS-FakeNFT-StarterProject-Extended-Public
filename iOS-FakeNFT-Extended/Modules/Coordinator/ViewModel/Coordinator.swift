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
	private let localStorage = StorageActor.shared
	private var path = [Page]()
	private var sheet: Sheet?
	private var fullScreenCover: FullScreenCover?
	private var ratingViewIsPresented = false
	
	init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}
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
		print("Navigation path updated to: \(newValue.debugDescription)")
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
		// no lifecycle handler 'cause of onSplashComplete calls once, user cannot call onSplashComplete by himself
		Task(priority: .userInitiated) {
			async let isOnboardingComplete: Bool? = localStorage.value(forKey: Constants.isOnboardingCompleteKey)
			async let isAuthed: Bool? = localStorage.value(forKey: Constants.isAuthedKey)

			let (onboarded, authed) = await (isOnboardingComplete ?? false, isAuthed ?? false)
			
			let newPage: Page
			if onboarded {
				if authed {
					newPage = .tabView
				} else {
					newPage = .authorization(.login)
				}
			} else {
				newPage = .onboarding
			}
			
			await MainActor.run {
				var transaction = Transaction()
				transaction.disablesAnimations = true
				
				withTransaction(transaction) {
					path = [newPage]
				}
			}
		}
	}
	
	func onOnboardingComplete() {
		Task(priority: .userInitiated) {
			await localStorage.set(true, forKey: Constants.isOnboardingCompleteKey)
			
			await MainActor.run {
				var transaction = Transaction()
				transaction.disablesAnimations = true
				
				withTransaction(transaction) {
					path = [.authorization(.login)]
				}
			}
		}
	}
	
	func performRegistrationFlow() {
		push(.authorization(.reg))
	}
	
	func performForgotPasswordFlow() {
		push(.authorization(.restorePassword))
	}
	
	func onAuthorizationComplete() {
		Task(priority: .userInitiated) {
			await self.localStorage.set(true, forKey: Constants.isAuthedKey)
			
			await MainActor.run {
				var transaction = Transaction()
				transaction.disablesAnimations = true
				
				withTransaction(transaction) {
					path = [.tabView]
				}
			}
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
		case .splash:
			SplashView(onComplete: onSplashComplete)
			
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
			
		case let .nftDetail(nft, authorID, authorCollection, authorWebsiteURLString):
			NFTDetailView(
				model: nft,
				nftService: appContainer.nftService,
				currenciesService: appContainer.currenciesService,
				getUser: appContainer.api.getUser,
				authorID: authorID,
				authorCollection: authorCollection,
				authorWebsiteURLString: authorWebsiteURLString,
				push: push,
				backAction: pop
			)

		case .profile(let profilePage):
			buildFlow(profilePage)

		case .catalog(let catalogFlow):
			buildFlow(catalogFlow)

		case .statistics(let statisticsFlow):
			buildFlow(statisticsFlow)
			
		case .cart(let cartFlow):
			buildFlow(cartFlow)
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

// -- statistics flow builder
extension Coordinator {
	@ViewBuilder
	func buildFlow(_ page: StatisticsPage) -> some View {
		switch page {
		case .nftCollection(
			let nftsIDs,
			let authorID,
			let authorWebsiteURLString
		):
			StatisticsNFTCollectionView(
				initialNFTsIDs: nftsIDs,
				authorID: authorID,
				loadingState: appContainer.api.loadingState,
				nftService: appContainer.nftService,
				loadAuthor: appContainer.api.getUser,
				didTapDetail: { [weak self] model, authorCollection in
					self?.push(
						.nftDetail(
							model: model,
							authorID: authorID,
							authorCollection: authorCollection,
							authorWebsiteURLString: authorWebsiteURLString
						)
					)
				}
			)
			
		case .profile(let profile):
			StatisticsProfileView(
				api: appContainer.api,
				push: push,
				model: profile
			)
		}
	}
}

// --- cart flow builder ---
private extension Coordinator {
	@ViewBuilder
	func buildFlow(_ page: CartPage) -> some View {
		switch page {
		case .paymentMethodChoose:
			PaymentMethodChooseView(
				currenciesService: appContainer.currenciesService,
				cartService: appContainer.cartService,
				onComplete: { [weak self] in self?.push(.cart(.successPayment)) }
			)
			
		case .successPayment:
			SuccessPaymentView(backToCart: popToRoot)
		}
	}
}

// --- catalog flow builder ---
private extension Coordinator {
    @ViewBuilder
    func buildFlow(_ page: CatalogPage) -> some View {
        switch page {
        case .catalogDetails(let catalog):
            CatalogNFTCollectionView(
				backAction: pop,
				performAuthorSite: { [weak self] in self?.push(.aboutAuthor(urlString: $0)) },
                catalog: catalog,
                nftService: appContainer.nftService
            )
        }
    }
}

// --- profile flow builder ---
private extension Coordinator {
    @ViewBuilder
    func buildFlow(_ page: ProfilePage) -> some View {
        switch page {
        case .editProfile(let profile):
            EditProfileView(
                profile: profile,
                profileService: appContainer.profileService,
                onCancel: pop
            )
        case .myNFTs:
			MyNFTView(
				favoritesService: appContainer.nftService.favouritesService,
				loadNFT: appContainer.api.getNFT,
				loadPurchasedNFTs: appContainer.purchasedNFTsService.get
			)

        case .favoriteNFTs:
			FavoriteNFTView(service: appContainer.nftService)

        }
    }
}
