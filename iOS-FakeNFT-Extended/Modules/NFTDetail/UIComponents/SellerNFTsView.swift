//
//  SellerNFTsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

fileprivate let nftWidth: CGFloat = 108

struct SellerNFTsView: View {
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
				ForEach(
					Array(viewModel.visibleNFTs.enumerated()),
					id: \.offset
				) { _, model in
					NFTVerticalCell(
						model: model,
						didTapDetail: didTapDetail,
						likeAction: { viewModel.didTapLikeButton(for: model) },
						cartAction: { viewModel.didTapCartButton(for: model) }
					)
					.id((model?.id ?? UUID().uuidString) + viewModel.modelUpdateTriggerID.uuidString)
					.frame(width: nftWidth)
					.cellModifiers()
				}
			}
			.padding(.horizontal)
		}
		.animation(Constants.defaultAnimation, value: viewModel.visibleNFTs)
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
	@Previewable let storage = NFTStorage()
	@Previewable @State var path: [Page] = [
		.nftDetail(
			model: .mock,
			authorID: "ab33768d-02ac-4f45-9890-7acf503bde54",
			authorWebsiteURLString: ""
		)
	]
	
	@Previewable @State var excludingNFTID = ""
	let authorID = "ab33768d-02ac-4f45-9890-7acf503bde54"
//	let authorID = "ef96b1c3-c495-4de5-b20f-1c1e73122b7d"
	
	NavigationStack(path: $path) {
		ZStack {
			SellerNFTsView(
				authorID: authorID,
				didTapDetail: {
					path
						.append(
							.nftDetail(
								model: $0,
								authorID: authorID,
								authorWebsiteURLString: ""
							)
						)
				},
				excludingNFTID: excludingNFTID,
				nftService: NFTService(api: api, storage: storage),
				loadAuthor: api.getUser
			)
		}
		.task(priority: .userInitiated) {
			do {
				excludingNFTID = try await api.getUser(by: authorID).nftsIDs.first ?? ""
			} catch { print(error.localizedDescription) }
		}
	}
}
#endif
