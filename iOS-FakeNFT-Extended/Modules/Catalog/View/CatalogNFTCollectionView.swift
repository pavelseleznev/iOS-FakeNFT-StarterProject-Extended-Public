//
//  CatalogNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Nikita Khon on 23.12.2025.
//

import SwiftUI

fileprivate let coverImageWidthHeightRatio: CGFloat = 0.75

struct CatalogNFTCollectionView: View {
	private let catalog: NFTCollectionItemResponse
	private let nftService: NFTServiceProtocol
	private let performAuthorSite: (String) -> Void
	private let backAction: () -> Void
	
	@State private var topToolbarIsVisible = false
	@State private var bottomToolbarIsVisible = false
	
	init(
		backAction: @escaping () -> Void,
		performAuthorSite: @escaping (String) -> Void,
		catalog: NFTCollectionItemResponse,
		nftService: NFTServiceProtocol
	) {
		self.catalog = catalog
		self.performAuthorSite = performAuthorSite
		self.nftService = nftService
		self.backAction = backAction
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				Color.ypWhite.ignoresSafeArea()
				
				ScrollView(.vertical) {
					VStack(spacing: .zero) {
						AsyncImageCached(urlString: catalog.coverImageURL?.absoluteString ?? "") { phase in
							switch phase {
							case .empty, .error:
								Color.ypBackgroundUniversal
									.overlay {
										ProgressView()
											.progressViewStyle(.circular)
									}
							case .loaded(let uIImage):
								Image(uiImage: uIImage)
									.resizable()
							}
						}
						.scaledToFill()
						.frame(height: geo.size.width * coverImageWidthHeightRatio)
						.clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12))
						.stretchy()
						
						VStack(spacing: .zero) {
							Text(catalog.name)
								.foregroundStyle(.ypBlack)
								.font(.bold22)
								.frame(maxWidth: .infinity, alignment: .leading)
							
							HStack {
								Text("Автор коллекции:") // TODO: Localize
									.foregroundStyle(.ypBlack)
									.font(.regular13)
								
								Button {
									guard let urlString = catalog.coverImageURL?.absoluteString else { return }
									performAuthorSite(urlString)
								} label: {
									Text(catalog.author)
										.foregroundStyle(.ypBlueUniversal)
										.font(.regular15)
								}
								.buttonStyle(.plain)
								.contentShape(Rectangle())
							}
							.padding(.top, 8)
							.frame(maxWidth: .infinity, alignment: .leading)
							
							Text(catalog.description)
								.foregroundStyle(.ypBlack)
								.font(.regular13)
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding(.top, 4)
						}
						.padding(.top, 16)
						.padding(.horizontal, 16)
						
						NFTCollectionView(
							initialNFTsIDs: catalog.nftsIDs,
							nftService: nftService,
							hidesToolbar: true
						)
						.scrollDisabled(true)
						.safeAreaPadding(.bottom)
						.padding(.bottom, 20)
						.padding(.top, 24)
					}
					.overlay(alignment: .top) {
						NFTDetailScrollViewHandlerView(scrollCoordinateSpace: "scroll")
					}
				}
				.scrollContentBackground(.hidden)
				.scrollIndicators(.hidden)
				.ignoresSafeArea(edges: .top)
			}
			.safeAreaInset(edge: .top) {
				let height = geo.safeAreaInsets.top - 16
				let limitedHeight = height.isFinite && height > 0 ? height : 0
				
				HStack {
					Button(action: backAction) {
						Image.chevronLeft
							.font(.bold22)
							.foregroundStyle(.ypBlack)
							.frame(width: 44, height: 44)
							.background(
								Circle()
									.fill(.ultraThinMaterial)
									.strokeBorder(.regularMaterial, lineWidth: 0.5)
							)
					}
					Spacer()
				}
				.background(
					Rectangle()
						.fill(.ypWhite)
						.blur(radius: 50, opaque: false)
						.frame(width: limitedHeight * 20, height: limitedHeight * 4)
						.offset(y: -limitedHeight * 2)
						.ignoresSafeArea()
				)
				.frame(height: limitedHeight)
				.padding(.leading, 8)
			}
		}
	}
}

#Preview {
	CatalogNFTCollectionView(
		backAction: {},
		performAuthorSite: {_ in},
		catalog: .mock1,
		nftService: NFTService.mock
	)
}
