//
//  NFTDetailView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

fileprivate let scrollCoordinateSpace = "scroll"
fileprivate let spacing: CGFloat = 24

struct NFTDetailView: View {
	private let backAction: () -> Void
	
	@State private var viewModel: NFTDetailViewModel
	@State private var isImageFullScreen = false
	@State private var isImageDissapeared = false
	
	init(
		model: NFTModelContainer,
		appContainer: AppContainer,
		authorID: String,
		authorWebsiteURLString: String,
		push: @escaping (Page) -> Void,
		backAction: @escaping () -> Void
	) {
		self.backAction = backAction
		
		_viewModel = .init(
			initialValue: .init(
				appContainer: appContainer,
				model: model,
				authorID: authorID,
				authorWebsiteURLString: authorWebsiteURLString,
				push: push
			)
		)
	}
	
	var body: some View {
		GeometryReader { geo in
			ScrollView(.vertical) {
				LazyVStack(spacing: spacing) {
					NFTDetailImagesView(
						nftsImagesURLsStrings: viewModel.model.nft.imagesURLsStrings,
						screenWidth: geo.size.width,
						isFavourite: viewModel.model.isFavorite,
						isFullScreen: $isImageFullScreen
					)
					.frame(height: imageViewHeight(geo: geo))
					.padding(.bottom, spacing)
					.overlay(alignment: .top) {
						SwipeSuggestionChevronView(
							isImageFullScreen: isImageFullScreen,
							screenWidth: geo.size.width
						)
					}
					
					VStack(spacing: spacing) {
						NFTDetailAboutView(nft: viewModel.model.nft)
						
						Divider().padding(.horizontal)
						
						NFTDetailCostWithAddToCartView(
							model: viewModel.model,
							cartAction: viewModel.didTapCartButton,
							modelUpdateTriggerID: viewModel.modelUpdateTriggerID
						)
						
						NFTDetailCurrenciesView(
							currencies: viewModel.visibleCurrencies,
							cost: viewModel.model.nft.price
						)
						
						NFTDetailGoToSellerSiteButtonView(
							action: viewModel.didTapGoToSellerSite,
							spacing: spacing
						)
						
						SellerNFTsView(
							authorID: viewModel.authorID,
							didTapDetail: viewModel.didTapDetail,
							excludingNFTID: viewModel.model.id,
							nftService: viewModel.appContainer.nftService,
							loadAuthor: viewModel.appContainer.api.getUser
						)
					}
					.scaleEffect(y: isImageFullScreen ? 0 : 1, anchor: .bottom)
				}
				.overlay(alignment: .top) {
					NFTDetailScrollViewHandlerView(
						mainGeo: geo,
						scrollCoordinateSpace: scrollCoordinateSpace,
						isImageFullScreen: $isImageFullScreen,
						isImageDissapeared: $isImageDissapeared
					)
				}
			}
			.scrollDisabled(isImageFullScreen)
			.scrollIndicators(.hidden)
			.scrollContentBackground(.hidden)
			.coordinateSpace(name: scrollCoordinateSpace)
			.ignoresSafeArea(edges: .top)
			.background(.ypWhite)
			.overlay(alignment: .top) {
				NFTDetailToolbarView(
					model: viewModel.model,
					isImageFullScreen: $isImageFullScreen,
					isImageDissapeared: isImageDissapeared,
					backAction: backAction,
					didTapLikeButton: viewModel.didTapLikeButton,
					modelUpdateTriggerID: viewModel.modelUpdateTriggerID
				)
			}
		}
		.toolbar(.hidden)
		.task(priority: .userInitiated) {
			await viewModel.loadCurrencies()
		}
		.applyRepeatableAlert(
			isPresneted: $viewModel.currenciesLoadErrorIsPresented,
			message: .cantGetCurrencies,
			didTapRepeat: {
				Task(priority: .high) {
					await viewModel.loadCurrencies()
				}
			}
		)
	}
	
	func imageViewHeight(geo: GeometryProxy) -> CGFloat {
		withAnimation(Constants.defaultAnimation) {
			isImageFullScreen ? geo.size.height + geo.safeAreaInsets.bottom : geo.size.width
		}
	}
}


#if DEBUG
#Preview {
	@Previewable let authorID = "ab33768d-02ac-4f45-9890-7acf503bde54"
//	@Previewable let authorID = "ef96b1c3-c495-4de5-b20f-1c1e73122b7d"
	@Previewable let storage = NFTStorage()
	@Previewable let api = ObservedNetworkClient()
	
	NFTDetailView(
		model: .mock,
		appContainer: .init(
			nftService: NFTService(
				api: api,
				storage: storage
			),
			api: api
		),
		authorID: authorID,
		authorWebsiteURLString: "",
		push: {_ in},
		backAction: {}
	)
}
#endif
