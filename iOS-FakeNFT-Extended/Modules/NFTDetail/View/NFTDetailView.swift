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
	private let nftService: NFTServiceProtocol
	private let getUser: (String) async throws -> UserListItemResponse
	private let backAction: () -> Void
	
	@State private var viewModel: NFTDetailViewModel
	@State private var isImageFullScreen = false
	@State private var isImageDissapeared = false
	
	init(
		model: NFTModelContainer,
		nftService: NFTServiceProtocol,
		cartService: CartServiceProtocol,
		getUser: @escaping (String) async throws -> UserListItemResponse,
		authorID: String,
		authorWebsiteURLString: String,
		push: @escaping (Page) -> Void,
		backAction: @escaping () -> Void
	) {
		self.getUser = getUser
		self.nftService = nftService
		self.backAction = backAction
		
		_viewModel = .init(
			initialValue: .init(
				cartService: cartService,
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
				VStack(spacing: spacing) {
					NFTDetailImagesView(
						nftsImagesURLsStrings: viewModel.model.nft.imagesURLsStrings,
						screenWidth: screenWidth(geo: geo),
						isFavourite: viewModel.model.isFavorite,
						isFullScreen: $isImageFullScreen
					)
					.frame(height: imageViewHeight(geo: geo))
					.padding(.bottom, spacing)
					.overlay(alignment: .top) {
						SwipeSuggestionChevronView(
							isImageFullScreen: isImageFullScreen,
							screenWidth: screenWidth(geo: geo)
						)
					}
					
					if !isImageFullScreen {
						VStack(spacing: spacing) {
							NFTDetailAboutView(nft: viewModel.model.nft)
							
							Divider().padding(.horizontal)
							
							NFTDetailCostWithAddToCartView(
								model: viewModel.model,
								cartAction: viewModel.didTapCartButton,
								modelUpdateTriggerID: viewModel.modelUpdateTriggerID
							)
							
							NFTDetailCurrenciesView(
								currencies: viewModel.currencies,
								cost: viewModel.model.nft.price
							)
							
							NFTDetailGoToSellerSiteButtonView(
								action: viewModel.didTapGoToSellerSite,
								spacing: spacing
							)
							
							SellerNFTsView(
								authorID: viewModel.authorID,
								authorCollection: viewModel.authorCollection,
								didTapDetail: viewModel.didTapDetail,
								excludingNFTID: viewModel.model.id,
								nftService: nftService,
								loadAuthor: getUser
							)
						}
						.transition(
							.move(edge: .bottom)
							.combined(with: .opacity)
							.animation(Constants.defaultAnimation)
						)
					}
				}
				.overlay(alignment: .top) {
					NFTDetailScrollViewHandlerView(
						scrollCoordinateSpace: scrollCoordinateSpace
					)
				}
			}
			.coordinateSpace(name: scrollCoordinateSpace)
			.onPreferenceChange(ScrollOffsetPreferenceKey.self) {
				handlePreferenceOffsetChange($0, screenWidth: screenWidth(geo: geo))
			}
			.scrollDisabled(isImageFullScreen)
			.scrollIndicators(.hidden)
			.scrollContentBackground(.hidden)
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
				Task(priority: .userInitiated) {
					await viewModel.loadCurrencies()
				}
			}
		)
	}
	
	func imageViewHeight(geo: GeometryProxy) -> CGFloat {
		let height = isImageFullScreen ? geo.size.height + geo.safeAreaInsets.bottom : geo.size.width
		return height
	}
	
	func screenWidth(geo: GeometryProxy) -> CGFloat {
		let width = geo.size.width
		return width
	}
	
	func handlePreferenceOffsetChange(_ offset: CGFloat, screenWidth: CGFloat) {
		let threshold: CGFloat = 100
		
		if offset > threshold {
			withAnimation(.default) {
				isImageFullScreen = true
			}
		}
		
		let shouldDissaper = offset < -screenWidth + threshold
		if isImageDissapeared != shouldDissaper {
			isImageDissapeared = shouldDissaper
		}
	}
}


#if DEBUG
#Preview {
	@Previewable @State var nfts = [
		NFTModelContainer.mock,
		NFTModelContainer.mock,
		NFTModelContainer.mock,
		NFTModelContainer.mock,
		NFTModelContainer.mock,
	]
	.map { (key: $0.id, value: $0) }
	
	@Previewable let authorIDWithNFTs = "ab33768d-02ac-4f45-9890-7acf503bde54"
	@Previewable let authorIDWithoutNFTs = "ef96b1c3-c495-4de5-b20f-1c1e73122b7d"
	@Previewable let needsNFTs = true
	
	let api = ObservedNetworkClient()
	lazy var orderService = NFTsIDsService(
		api: api,
		kind: .order
	)
	lazy var cartService = CartService(
		orderService: orderService,
		api: api
   )
	
	lazy var nftService = NFTService(
		favouritesService: NFTsIDsService(
			api: api,
			kind: .favorites
		),
		orderService: orderService,
		loadNFT: api.getNFT
	)
	
	NFTDetailView(
		model: .mock,
		nftService: nftService,
		cartService: cartService,
		getUser: api.getUser,
		authorID: authorID,
		authorWebsiteURLString: "",
		push: {_ in},
		backAction: {}
	)
}
#endif
