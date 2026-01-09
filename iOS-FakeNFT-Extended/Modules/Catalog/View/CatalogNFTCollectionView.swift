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
	private let loadCollection: @Sendable (String) async throws -> NFTCollectionItemResponse
	
	@State private var topToolbarIsVisible = false
	@State private var bottomToolbarIsVisible = false
	
	init(
		loadCollection: @escaping @Sendable (String) async throws -> NFTCollectionItemResponse,
		backAction: @escaping () -> Void,
		performAuthorSite: @escaping (String) -> Void,
		catalog: NFTCollectionItemResponse,
		nftService: NFTServiceProtocol
	) {
		self.catalog = catalog
		self.performAuthorSite = performAuthorSite
		self.nftService = nftService
		self.backAction = backAction
		self.loadCollection = loadCollection
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				Color.ypWhite.ignoresSafeArea()
				
				ScrollView(.vertical) {
					VStack(spacing: .zero) {
						CoverImageView(
							urlString: catalog.coverImageURLString,
							height: geo.size.width * coverImageWidthHeightRatio
						)
						
						AboutCollectionView(
							catalog: catalog,
							performAuthorSite: performAuthorSite
						)
						
						NFTCollectionView(
							initialNFTsIDs: catalog.nftsIDs,
							isFromCollection: true,
							collectionID: catalog.id,
							nftService: nftService,
							loadCollection: loadCollection,
							hidesToolbar: true
						)
						.scrollDisabled(true)
						.safeAreaPadding(.bottom)
						.padding(.bottom, 20)
						.padding(.top, 24)
					}
				}
				.scrollContentBackground(.hidden)
				.scrollIndicators(.hidden)
				.ignoresSafeArea(edges: .top)
			}
			.safeAreaInset(edge: .top) {
				let height = geo.safeAreaInsets.top - 16
				let limitedHeight = height.isFinite && height > 0 ? height : 0
				
				CustomBackButton(
					limitedHeight: limitedHeight,
					backAction: backAction
				)
			}
		}
	}
}

// MARK: - Subviews
fileprivate struct CustomBackButton: View {
	let limitedHeight: CGFloat
	let backAction: () -> Void
	
	var body: some View {
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


fileprivate struct AboutCollectionView: View {
	let catalog: NFTCollectionItemResponse
	let performAuthorSite: (String) -> Void
	
	var body: some View {
		VStack(spacing: .zero) {
			Text(catalog.name)
				.foregroundStyle(.ypBlack)
				.font(.bold22)
				.frame(maxWidth: .infinity, alignment: .leading)
			
			HStack {
                Text(.createdBy)
					.foregroundStyle(.ypBlack)
					.font(.regular13)
				
				Button {
					// MARK: - не грузится? - норм! - с апи призодят битые url
					performAuthorSite(catalog.websiteURLString)
				} label: {
					Text(catalog.authorName)
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
	}
}

fileprivate struct CoverImageView: View {
	let urlString: String
	let height: CGFloat
	var body: some View {
		AsyncImageCached(urlString: urlString) { phase in
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
		.frame(height: height)
		.clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 0, bottomTrailingRadius: 0))
		.stretchy()
	}
}


// MARK: - Preview
#Preview {
	CatalogNFTCollectionView(
		loadCollection: ObservedNetworkClient().getCollection,
		backAction: {},
		performAuthorSite: {_ in},
		catalog: .mock1,
		nftService: NFTService.mock
	)
}
