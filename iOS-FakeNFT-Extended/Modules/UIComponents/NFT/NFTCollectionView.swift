//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTCollectionView: View {
	@StateObject private var debouncingViewModel = DebouncingViewModel()
	@StateObject private var viewModel: NFTCollectionViewModel
	
	@Environment(\.isSearching) private var isSearching
	@State private var isSearchingState = false
	private let hidesToolbar: Bool
	
	init(
		initialNFTsIDs: [String],
		isFromCollection: Bool = false,
		authorID: String = "",
		collectionID: String = "",
		nftService: NFTServiceProtocol,
		loadAuthor: @escaping @Sendable (String) async throws -> UserListItemResponse = { _ in .mock },
		loadCollection: @escaping @Sendable (String) async throws -> NFTCollectionItemResponse = { _ in .mock1 },
		didTapDetail: @escaping (NFTModelContainer, [Dictionary<String, NFTModelContainer?>.Element]) -> Void = { _, _ in },
		hidesToolbar: Bool = false
	) {
		self.hidesToolbar = hidesToolbar
		
		_viewModel = .init(
			wrappedValue: .init(
				loadAuthor: loadAuthor,
				loadCollection: loadCollection,
				nftService: nftService,
				initialNFTsIDs: initialNFTsIDs,
				isFromCollection: isFromCollection,
				collectionID: collectionID.isEmpty ? nil : collectionID,
				authorID: authorID.isEmpty ? nil : authorID,
				didTapDetail: didTapDetail
			)
		)
	}
	
	private let columns = [
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top)
	]
	
	var body: some View {
		ZStack {
			ScrollView(.vertical) {
				LazyVGrid(
					columns: columns,
					alignment: .center,
					spacing: 28,
					pinnedViews: .sectionHeaders
				) {
					ForEach(viewModel.filteredKeys, id: \.self) { key in
						let model = viewModel.nfts[key] ?? nil
						
						NFTVerticalCell(
							model: model,
							didTapDetail: viewModel.didTapDetailOnCell,
							likeAction: {
								viewModel.didTapLikeButton(for: model)
							},
							cartAction: {
								viewModel.didTapCartButton(for: model)
							}
						)
					}
					.scrollTransition { content, phase in
						content
							.rotation3DEffect(
								.degrees(phase.isIdentity ? 0 : 10 * phase.value),
								axis: (x: phase.isIdentity ? 0 : 1, y: 0, z: 0)
							)
							.blur(radius: phase.isIdentity ? 0 : 1, opaque: false)
							.opacity(phase.isIdentity ? 1 : 0.7)
					}
				}
				.collectionSearchable(
					text: $debouncingViewModel.text,
					activeTokens: $viewModel.activeTokens,
					tokenAction: viewModel.tokenAction,
					isSearching: $isSearchingState,
					hidesToolbar: hidesToolbar,
					didCancel: { viewModel.onDebounce("") }
				)
				.animation(Constants.defaultAnimation, value: viewModel.activeTokens)
			}
			.layout(isSearchingState: isSearchingState)
			.scrollModifiers()
			.overlay(alignment: .center, content: emptyNFTsView)
			.overlay(alignment: .bottomTrailing, content: filtrationButton)
			.applyRepeatableAlert(
				isPresented: $viewModel.errorIsPresented,
				message: .cantGetNFTs,
				didTapRepeat: viewModel.startBackgroundUnloadedLoadPolling
			)
			.onChange(of: isSearching, onIsSearchingChanged)
			.onAppear(perform: setDebouncingHandler)
			.lifeCycle(
				onAppear: viewModel.startBackgroundUnloadedLoadPolling,
				onDisappear: viewModel.viewDidDissappear
			)
			.onReceive(
				NotificationCenter.default.publisher(for: .nftDidChange),
				perform: viewModel.handleNFTChangeNotification
			)
			.onChange(of: viewModel.activeTokens) { HapticPerfromer.shared.play(.selection) }
		}
	}
}

// MARK: - NFTCollectionView Extensions
// --- subviews ---
private extension NFTCollectionView {
	@ViewBuilder
	func emptyNFTsView() -> some View {
		if viewModel.filteredKeys.isEmpty {
			EmptyContentView(type: .nfts)
		}
	}
	
	@ViewBuilder
	func filtrationButton() -> some View {
		if isSearchingState {
			NFTCollectionFiltrationButtonView()
				.environmentObject(viewModel)
		}
	}
}

// --- methods ---
private extension NFTCollectionView {
	private func setDebouncingHandler() {
		debouncingViewModel.onDebounce = viewModel.onDebounce
	}
	
	private func onIsSearchingChanged(_: Bool, _: Bool) {
		withAnimation(Constants.defaultAnimation) {
			isSearchingState = isSearching
		}
	}
}

// MARK: - View helper
fileprivate extension View {
	func lifeCycle(
		onAppear: @escaping () -> Void,
		onDisappear: @escaping () -> Void
	) -> some View {
		self
			.onAppear(perform: onAppear)
			.onDisappear(perform: onDisappear)
	}
	
	func layout(isSearchingState: Bool) -> some View {
		self
			.contentMargins(.bottom, isSearchingState ? 60 + 32 : 0)
			.padding(.horizontal, 16)
	}
	
	func scrollModifiers() -> some View {
		self
			.scrollIndicators(.hidden)
			.scrollDismissesKeyboard(.interactively)
	}
	
	func collectionSearchable(
		text: Binding<String>,
		activeTokens: Binding<[FilterToken]>,
		tokenAction: @escaping (FilterToken) -> Void,
		isSearching: Binding<Bool>,
		hidesToolbar: Bool,
		didCancel: @escaping () -> Void
	) -> some View {
		self
			.autocorrectionDisabled()
			.textInputAutocapitalization(.never)
			.searchable(
				text: Binding(
					get: { text.wrappedValue },
					set: { newValue in
						
						text.wrappedValue = newValue
						if newValue.isEmpty {
							didCancel()
						}
					}
				),
				tokens: activeTokens,
				isPresented: Binding(
					get: { isSearching.wrappedValue },
					set: { newValue in
						
						isSearching.wrappedValue = newValue
						if newValue == false {
							didCancel()
						}
					}
				),
				placement: .navigationBarDrawer(displayMode: .always),
				prompt: .search,
				token: { Text($0.title) }
			)
			.toolbar(hidesToolbar ? .hidden : .visible)
			.toolbar {
				ToolbarItem(placement: .destructiveAction) {
					NFTCollectionToolbarView(
						activeTokens: activeTokens,
						tokenAction: tokenAction,
						isActive: { activeTokens.wrappedValue.contains($0) },
						atLeastOneSelected: !activeTokens.wrappedValue.isEmpty,
					)
					.font(.bold22)
				}
			}
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	NavigationStack {
		ZStack {
			Color.ypWhite
				.ignoresSafeArea()
			NFTCollectionView(
				initialNFTsIDs: [
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
				authorID: "ab33768d-02ac-4f45-9890-7acf503bde54",
				nftService: NFTService.mock,
				loadAuthor: ObservedNetworkClient().getUser,
				didTapDetail: {_, _ in}
			)
		}
		.customNavigationBackButton(hasNotBackButton: true, backAction: {})
	}
}
#endif
