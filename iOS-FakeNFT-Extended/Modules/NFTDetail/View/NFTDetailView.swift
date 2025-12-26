//
//  NFTDetailView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

struct NFTDetailView: View {
	@State private var viewModel: NFTDetailViewModel
	@State private var isImageFullScreen = false
	@State private var isImageDissapeared = false
	@State private var isOverscrolling = false
	@State private var scrollOffset: CGFloat = 0
	
	private let scrollCoordinateSpace = "scroll"
	
	init(
		model: NFTModelContainer,
		appContainer: AppContainer,
		authorID: String,
		authorWebsiteURLString: String,
		push: @escaping (Page) -> Void, // TODO: pass just goTo callback
		pop: @escaping () -> Void
	) {
		_viewModel = .init(
			initialValue: .init(
				appContainer: appContainer,
				model: model,
				authorID: authorID,
				authorWebsiteURLString: authorWebsiteURLString,
				push: push,
				pop: pop
			)
		)
	}
	
	var body: some View {
		GeometryReader { geo in
			ScrollViewReader { proxy in
				ScrollView(.vertical) {
					LazyVStack(spacing: 24) {
						NFTDetailImagesView(
							nftsImagesURLsStrings: viewModel.model.nft.imagesURLsStrings,
							isFavourite: viewModel.model.isFavorite,
							isFullScreen: isImageFullScreen
						)
						.frame(height: isImageFullScreen ? geo.size.height + geo.safeAreaInsets.bottom : geo.size.width)
						.toolbar(.visible)
						.padding(.bottom, 28)
						
						aboutView
						
						Divider().padding(.horizontal)
						
						costWithAddToCartView
						
						NFTDetailCurrenciesView(
							currencies: viewModel.visibleCurrencies,
							cost: viewModel.model.nft.price
						)
						
						gotToSellerSiteView
						
						SellerNFTsView(
							authorID: viewModel.authorID,
							didTapDetail: viewModel.didTapDetail,
							excludingNFTID: viewModel.model.id,
							nftService: viewModel.appContainer.nftService,
							loadAuthor: viewModel.appContainer.api.getUser
						)
						.padding(.top, 24)
					}
					.overlay(alignment: .top) {
						geometryReaderView(mainGeo: geo)
					}
				}
				.background(.ypWhite)
				.toolbar(.hidden)
				.scrollIndicators(.hidden)
				.scrollContentBackground(.hidden)
				.coordinateSpace(name: scrollCoordinateSpace)
				.animation(.easeInOut(duration: 0.15), value: viewModel.model)
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
				.ignoresSafeArea(edges: .top)
				.overlay(alignment: .top) { toolbarView }
			}
		}
		.onDisappear(perform: viewModel.clearAllTasks)
	}
	
	private var toolbarView: some View {
		HStack {
			Group {
				if isImageFullScreen {
					HStack {
						Spacer()
						Button {
							withAnimation(.easeInOut(duration: 0.25)) {
								isImageFullScreen = false
							}
						} label: {
							Image.xmark
								.resizable()
								.font(.xmarkIcon)
								.foregroundStyle(.ypBlack)
								.frame(width: 18, height: 18)
								.frame(width: 24, height: 24)
						}
					}
				} else {
					Button(action: viewModel.pop) {
						Image.chevronLeft
							.resizable()
							.font(.chevronLeftIcon)
							.foregroundStyle(.ypBlack)
							.frame(width: 9, height: 16)
							.frame(width: 24, height: 24)
					}
					Spacer()
					Button(action: viewModel.didTapLikeButton) {
						Image.heartFill
							.resizable()
							.foregroundStyle(
								viewModel.model.isFavorite ? .ypRedUniversal : .secondary
							)
							.frame(width: 21, height: 18)
							.frame(width: 24, height: 24)
							.id(viewModel.modelUpdateTriggerID)
					}
				}
			}
			.shadow(
				color: isImageDissapeared ? .clear : .ypWhite,
				radius: 10
			)
			.offset(y: 8)
		}
		.padding(.horizontal, 8)
		.padding(.trailing, 4)
		.padding(.bottom)
		.background(
			RoundedRectangle(cornerRadius: isImageDissapeared ? 0 : 0)
				.fill(.ultraThinMaterial)
				.shadow(color: .ypBlackUniversal.opacity(0.3), radius: 10)
				.opacity(isImageDissapeared ? 1 : 0)
				.ignoresSafeArea(edges: .top)
		)
		
	}
	
	private func geometryReaderView(mainGeo: GeometryProxy) -> some View {
		GeometryReader { geo in
			let offset = geo.frame(in: .named(scrollCoordinateSpace)).minY
			
			Color.clear
				.onAppear {
					scrollOffset = offset
				}
				.onChange(of: offset) { _, newValue in
					let threshold: CGFloat = 150
					scrollOffset = newValue
					
					withAnimation(.easeInOut(duration: 0.25)) {
						if newValue > 0 {
							isOverscrolling = true
						} else {
							isOverscrolling = false
						}
						
						if newValue > threshold {
							isImageFullScreen = true
						} else if newValue < -threshold {
							isImageFullScreen = false
						}
						
						let dissapearThreshold: CGFloat = -mainGeo.size.width + 100
						
						if newValue < dissapearThreshold {
							isImageDissapeared = true
						} else if newValue > dissapearThreshold {
							isImageDissapeared = false
						}
					}
				}
		}
		.frame(height: 0)
	}
	
	private var gotToSellerSiteView: some View {
		Button(action: viewModel.didTapGoToSellerSite) {
			Text(.goToUserSite)
		}
		.nftButtonStyle(filled: false)
		.padding(.horizontal)
		.padding(.top, -12)
	}
	
	private var costWithAddToCartView: some View {
		HStack(spacing: 27) {
			NFTCostView(model: viewModel.model.nft, layout: .cart)
			
			Button(action: viewModel.cartAction) {
				Text(
					viewModel.model.isInCart ? .removeFromCartText : .addToCartText)
					.font(.bold17)
					.foregroundStyle(.ypWhite)
			}
			.nftButtonStyle(filled: true)
			.offset(y: -10)
			.id(viewModel.modelUpdateTriggerID)
		}
		.padding(.horizontal)
	}
	
	private var aboutView: some View {
		HStack(spacing: 8) {
			Text(viewModel.model.nft.name)
				.font(.bold22)
				.foregroundStyle(.ypBlack)
				.frame(maxWidth: 100)
			
			RatingPreview(rating: viewModel.model.nft.rating)
			
			Spacer()
			
			Text(viewModel.model.nft.authorName)
				.font(.bold17)
				.foregroundStyle(.ypBlack)
				.frame(maxWidth: 100)
		}
		.padding(.horizontal)
	}
}


#if DEBUG
#Preview {
//	@Previewable let authorID = "ab33768d-02ac-4f45-9890-7acf503bde54"
	@Previewable let authorID = "ef96b1c3-c495-4de5-b20f-1c1e73122b7d"
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
		pop: {}
	)
}
#endif
