//
//  CoordinatorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct CoordinatorView: View {
	@State private var coordinator: Coordinator
	
	var body: some View {
		NavigationStack(path: $coordinator.path) {
			coordinator.build(.tabView)
				.navigationDestination(for: Page.self) { page in
                    let built = coordinator.build(page).overlay(content: loadingView)
                    switch page {
                    case .profile(.editProfile):
                        built
                    default:
                        built.customNavigationBackButton(backAction: coordinator.pop)
                            .overlay(content: loadingView)
                    }
				}
				.sheet(item: $coordinator.sheet) { sheet in
					coordinator.build(sheet)
				}
				.fullScreenCover(
					item: $coordinator.fullScreenCover
				) { fullScreenCover in
					coordinator.build(fullScreenCover)
				}
				.overlay(content: loadingView)
				.allowsHitTesting(coordinator.appContainer.api.loadingState != .fetching)
                //TODO: Uncomment for merge
				//.onAppear(perform: checkAuthState)
		}
	}
	
    init() {
        let api = ObservedNetworkClient()
        let profileStorage = ProfileStorage()
        
        let favouritedNFTsService = NFTsIDsService(api: api, kind: .favorites)
        let purchasedNFTsService = NFTsIDsService(api: api, kind: .purchased)
        let orderNFTsService = NFTsIDsService(api: api, kind: .order)
        
//        let cartService = CartService(
//            orderService: orderNFTsService,
//            api: api
//        )
        
        let profileService = ProfileService(api: api, storage: profileStorage)
        let nftService = NFTService(
            favouritesService: favouritedNFTsService,
            orderService: orderNFTsService,
            loadNFT: api.getNFT
        )
        
        let appContainer = AppContainer(
            profileService: profileService,
            purchasedNFTsService: purchasedNFTsService,
            //TODO: Uncomment for merge
            //cartService: cartService,
            nftService: nftService,
            api: api
        )
        _coordinator = State(initialValue: .init(appContainer: appContainer))
    }
	
	private func loadingView() -> some View {
		LoadingView(loadingState: coordinator.appContainer.api.loadingState)
	}
	
	private func checkAuthState() {
		coordinator.dismissFullScreenCover()
	}
}

#Preview {
	CoordinatorView()
}

extension View {
	func customNavigationBackButton(backAction: @escaping () -> Void) -> some View {
		self
			.navigationBarBackButtonHidden()
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button(action: backAction) {
						Image.chevronLeft
							.font(.chevronLeftIcon)
					}
					.tint(.ypBlack)
				}
			}
	}
}
