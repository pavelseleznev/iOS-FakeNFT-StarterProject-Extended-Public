//
//  SellerNFTsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

fileprivate let nftWidth: CGFloat = 108

struct SellerNFTsView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.viewModel.visibleNFTs.first?.value == rhs.viewModel.visibleNFTs.first?.value
	}
	
	@State private var viewModel: SellerNFTsViewModel
	
	private let didTapDetail: (NFTModelContainer) -> Void
	
	init(
		authorID: String,
		didTapDetail: @escaping (NFTModelContainer) -> Void,
		excludingNFTID: String,
		nftService: NFTServiceProtocol,
		loadAuthor: @escaping (String) async throws -> UserListItemResponse
	) {
		self.didTapDetail = didTapDetail
		
		_viewModel = .init(
			initialValue: .init(
				authorID: authorID,
				excludingNFTID: excludingNFTID,
				nftService: nftService,
				loadAuthor: loadAuthor
			)
		)
	}
	
	var body: some View {
		ScrollView(.horizontal) {
			LazyHStack(alignment: .top, spacing: 8) {
				ForEach(viewModel.visibleNFTs, id: \.key) { element in
					NFTVerticalCell(
						model: element.value,
						didTapDetail: didTapDetail,
						likeAction: { viewModel.didTapLikeButton(for: element.value) },
						cartAction: { viewModel.didTapCartButton(for: element.value) }
					)
					.frame(width: nftWidth)
					.cellModifiers()
					.id(element.key + viewModel.modelUpdateTriggerID.uuidString)
				}
			}
			.padding(.horizontal)
		}
		.scrollIndicators(.hidden)
		.applyRepeatableAlert(
			isPresneted: $viewModel.showAuthorLoadingError,
			message: .cantGetAuthor,
			didTapRepeat: viewModel.startPolling
		)
		.applyRepeatableAlert(
			isPresneted: $viewModel.showNFTsLoadingError,
			message: .cantGetNFTs,
			didTapRepeat: viewModel.startPolling
		)
		.onAppear(perform: viewModel.startPolling)
		.onDisappear(perform: viewModel.clearAllTasks)
		.overlay(alignment: .top, content: noNFTsView)
		.contentMargins(.vertical, 24)
		.onReceive(
			NotificationCenter.default.publisher(for: .nftDidChange),
			perform: viewModel.handleNFTChangeNotification
		)
	}
	
	@ViewBuilder
	private func noNFTsView() -> some View {
		if viewModel.visibleNFTs.isEmpty {
			EmptyContentView(type: .nfts)
				.transition(.scale.combined(with: .opacity))
		}
	}
}

// MARK: - View helper
fileprivate extension View {
	func cellModifiers() -> some View {
		self
			.scrollTransition { content, phase in
				content
					.rotation3DEffect(
						.degrees(phase.isIdentity ? 0 : 35 * -phase.value),
						axis: (x: 0, y: phase.isIdentity ? 1 : 0, z: 0)
					)
					.opacity(phase.isIdentity ? 1 : 0.7)
					.blur(radius: phase.isIdentity ? 0 : 2)
			}
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	@Previewable let api = ObservedNetworkClient()
	@Previewable @State var path: [Page] = [
		.nftDetail(
			model: .mock,
			authorID: "ab33768d-02ac-4f45-9890-7acf503bde54",
			authorWebsiteURLString: ""
		)
	]
	
	@Previewable @State var excludingNFTID = ""
	let authorIDWithSomeNFTs = "ab33768d-02ac-4f45-9890-7acf503bde54"
	let authorIDWithEmptyNFTs = "ef96b1c3-c495-4de5-b20f-1c1e73122b7d"
	
	NavigationStack(path: $path) {
		ZStack {
			SellerNFTsView(
				authorID: authorIDWithSomeNFTs,
				didTapDetail: {
					path
						.append(
							.nftDetail(
								model: $0,
								authorID: authorIDWithSomeNFTs,
								authorWebsiteURLString: ""
							)
						)
				},
				excludingNFTID: excludingNFTID,
				nftService: NFTService.mock,
				loadAuthor: api.getUser
			)
		}
		.task(priority: .userInitiated) {
			do {
				excludingNFTID = try await api.getUser(by: authorIDWithSomeNFTs).nftsIDs.first ?? ""
			} catch { print(error.localizedDescription) }
		}
	}
}
#endif
