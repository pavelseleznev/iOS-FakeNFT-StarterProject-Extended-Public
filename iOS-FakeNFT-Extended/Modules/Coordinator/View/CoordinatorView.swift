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
                    case .editProfile:
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
					item: $coordinator.fullScreencover
				) { fullScreenCover in
					coordinator.build(fullScreenCover)
				}
				.overlay(content: loadingView)
				.allowsHitTesting(coordinator.appContainer.api.loadingState != .fetching)
				.onAppear(perform: checkAuthState)
		}
	}
	
    init() {
        let api = ObservedNetworkClient()
        let nftStorage = NFTStorage()
        let nft = NFTService(api: api, storage: nftStorage)
        let appContainer = AppContainer(
            nftService: nft,
            api: api
        )
        let profileStore = ProfileStore(api: api, initial: ProfileModel.preview)
        _coordinator = State(initialValue: .init(
            appContainer: appContainer, profileStore: profileStore
        )
        )
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
