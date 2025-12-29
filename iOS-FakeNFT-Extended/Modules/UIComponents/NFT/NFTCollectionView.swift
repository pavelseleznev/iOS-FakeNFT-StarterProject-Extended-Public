//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTCollectionView: View {
	@StateObject private var debouncingViewModel = DebouncingViewModel()
	@StateObject private var asyncNFTs: AsyncNFTs
	private let didTapDetail: (NFTModelContainer) -> Void
	
	init(
		nftsIDs: [String],
		nftService: NFTServiceProtocol,
		didTapDetail: @escaping (NFTModelContainer) -> Void,
	) {
		self.didTapDetail = didTapDetail
		
		_asyncNFTs = .init(
			wrappedValue: .init(
				nftService: nftService,
				ids: Set(nftsIDs)
			)
		)
	}
	
	private let columns = [
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top)
	]
	
	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(
				columns: columns,
				alignment: .center,
				spacing: 28
			) {
				ForEach(
					Array(asyncNFTs.visibleNFTs.enumerated()),
					id: \.offset
				) { index, model in
					NFTVerticalCell(
						model: model,
						didTapDetail: didTapDetail,
						likeAction: {
							asyncNFTs.didTapLikeButton(for: model)
						},
						cartAction: {
							asyncNFTs.didTapCartButton(for: model)
						}
					)
					.transition(.scale.combined(with: .blurReplace))
				}
				.scrollTransition { content, phase in
					content
						.opacity(phase.isIdentity ? 1 : 0.45)
						.blur(radius: phase.isIdentity ? 0 : 5, opaque: false)
						.rotation3DEffect(
							.degrees(phase.isIdentity ? 0 : 25 * phase.value),
							axis: (x: phase.isIdentity ? 0 : 1, y: 0, z: 0)
						)
				}
			}
			.collectionSearchable(
				text: $debouncingViewModel.text,
				activeTokens: $asyncNFTs.activeTokens,
				tokenAction: asyncNFTs.tokenAction
			)
		}
		.animation(Constants.defaultAnimation, value: asyncNFTs.visibleNFTs)
		.padding(.horizontal, 16)
		.scrollIndicators(.hidden)
		.onDisappear(perform: asyncNFTs.clearAllATasks)
		.onAppear(perform: asyncNFTs.startBackgroundUnloadedLoadPolling)
		.onDisappear(perform: asyncNFTs.viewDidDissappear)
		.applyRepeatableAlert(
			isPresneted: $asyncNFTs.errorIsPresented,
			message: .cantGetNFTs,
			didTapRepeat: asyncNFTs.startBackgroundUnloadedLoadPolling
		)
		.overlay(alignment: .center, content: emptyNFTsView)
		.onReceive(
			NotificationCenter.default.publisher(for: .nftDidChange),
			perform: asyncNFTs.handleNFTChangeNotification
		)
		.onAppear {
			debouncingViewModel.onDebounce = asyncNFTs.onDebounce
		}
	}
	
	@ViewBuilder
	private func emptyNFTsView() -> some View {
		if asyncNFTs.visibleNFTs.isEmpty {
			EmptyContentView(type: .nfts)
		}
	}
}

// MARK: - View helper
private extension View {
	func collectionSearchable(
		text: Binding<String>,
		activeTokens: Binding<[FilterToken]>,
		tokenAction: @escaping (FilterToken) -> Void
	) -> some View {
		self
			.autocorrectionDisabled()
			.textInputAutocapitalization(.never)
			.scrollDismissesKeyboard(.interactively)
			.searchable(
				text: text,
				tokens: activeTokens,
				placement: .navigationBarDrawer(displayMode: .always),
				prompt: .search,
				token: { Text($0.title) }
			)
			.toolbar {
				ToolbarItem(placement: .destructiveAction) {
					Menu {
						ForEach(FilterToken.allCases) { token in
							let tokenIsActive = activeTokens.wrappedValue.contains(token)
							
							let title = String(localized: token.title)
							let buttonTitle: LocalizedStringResource = tokenIsActive ? .filterRemove(title: title) : .filterAdd(title: title)
							Button(
								buttonTitle,
								role: tokenIsActive ? .destructive : .cancel
							) {
								tokenAction(token)
							}
						}
					} label: {
						Image(systemName: "line.3.horizontal.decrease.circle.fill")
							.font(.bold22)
							.foregroundStyle(
								activeTokens.wrappedValue.isEmpty ? .ypBlack : .cyan
							)
					}

				}
			}
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	@Previewable let service = NFTService(
		api: .init(api: DefaultNetworkClient()),
			  storage: NFTStorage()
	  )
	
	NavigationStack {
		ZStack {
			Color.ypWhite
				.ignoresSafeArea()
			NFTCollectionView(
				nftsIDs: [
					"1fda6f0c-a615-4a1a-aa9c-a1cbd7cc76ae",
					"77c9aa30-f07a-4bed-886b-dd41051fade2",
					"b3907b86-37c4-4e15-95bc-7f8147a9a660",
					"f380f245-0264-4b42-8e7e-c4486e237504",
					"9810d484-c3fc-49e8-bc73-f5e602c36b40",
					"c14cf3bc-7470-4eec-8a42-5eaa65f4053c",
					"b2f44171-7dcd-46d7-a6d3-e2109aacf520",
					"e33e18d5-4fc2-466d-b651-028f78d771b8",
					"db196ee3-07ef-44e7-8ff5-16548fc6f434",
					"e8c1f0b6-5caf-4f65-8e5b-12f4bcb29efb",
					"739e293c-1067-43e5-8f1d-4377e744ddde",
					"d6a02bd1-1255-46cd-815b-656174c1d9c0",
					"de7c0518-6379-443b-a4be-81f5a7655f48",
					"82570704-14ac-4679-9436-050f4a32a8a0"
				],
				nftService: service,
				didTapDetail: {_ in}
			)
		}
		.customNavigationBackButton(hasBackButton: true, backAction: {})
	}
}
#endif
