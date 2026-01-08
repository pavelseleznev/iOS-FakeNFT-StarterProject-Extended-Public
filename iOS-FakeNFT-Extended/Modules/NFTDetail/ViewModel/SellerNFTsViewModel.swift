//
//  SellerNFTsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

private enum SellerNFTsLoadError: Error {
	case authorError
	case nftsError
}

@Observable
@MainActor
final class SellerNFTsViewModel {
	private let authorID: String
	private let excludingNFTID: String
	private let nftService: NFTServiceProtocol
	private let loadAuthor: (String) async throws -> UserListItemResponse
	@ObservationIgnored private let screenID = UUID()
	
	private let pollingInterval: Duration = .seconds(1)
	
	@ObservationIgnored private var nftsUpdateTask: Task<Void, Never>?
	
	@ObservationIgnored private var updatesID = UUID()
	private(set) var modelUpdateTriggerID = UUID()
	private(set) var nfts = [Dictionary<String, NFTModelContainer?>.Element]()
	var showAuthorLoadingError = false
	var showNFTsLoadingError = false

	init(
		authorID: String,
		authorCollection: [Dictionary<String, NFTModelContainer?>.Element],
		excludingNFTID: String,
		nftService: NFTServiceProtocol,
		loadAuthor: @escaping (String) async throws -> UserListItemResponse,
	) {
		nfts = authorCollection
		self.authorID = authorID
		self.excludingNFTID = excludingNFTID
		self.nftService = nftService
		self.loadAuthor = loadAuthor
	}
}
// MARK: - SellerNFTsViewModel Extensions
// --- internal methods ---
extension SellerNFTsViewModel {
	func startPolling() {
		startNFTsUpdatePolling()
	}
	
	func clearAllTasks() {
		clearNFTsUpdateTask()
	}
	
	func didTapCartButton(for model: NFTModelContainer?, isFromNotification: Bool = false) {
		guard let model else { return }
		if !isFromNotification { updatesID = UUID() }
		changeModelState(model: model, isCartChanged: true)
	}
	
	func didTapLikeButton(for model: NFTModelContainer?, isFromNotification: Bool = false) {
		guard let model else { return }
		if !isFromNotification { updatesID = UUID() }
		changeModelState(model: model, isFavoriteChanged: true)
	}
	
	func handleNFTChangeNotification(notification: Notification) {
		if
			let payload = notification.userInfo?[Constants.nftChangePayloadKey] as? NFTUpdatePayload,
			payload.screenID != screenID,
			payload.updatesID != payload.updatesID,
			payload.hasChanges,
			let model = nfts.first(where: { $0.key == payload.id })?.value
		{
			updatesID = payload.updatesID
			
			if payload.isCartChanged {
				didTapCartButton(for: model, isFromNotification: true)
			}
			
			if payload.isFavoriteChanged {
				didTapLikeButton(for: model, isFromNotification: true)
			}
		}
	}
}

// --- private methods ---
private extension SellerNFTsViewModel {
	func changeModelState(
		model: NFTModelContainer,
		isFavoriteChanged: Bool = false,
		isCartChanged: Bool = false,
	) {
		guard let index = nfts.firstIndex(where: { $0.key == model.id }) else { return }
		nfts[index].value = .init(
			nft: model.nft,
			isFavorite: isFavoriteChanged ? !model.isFavorite : model.isFavorite,
			isInCart: isCartChanged ? !model.isInCart : model.isInCart
		)
		
		withAnimation(Constants.defaultAnimation) {
			modelUpdateTriggerID = .init()
		}
		
		sendUpdateNotification(
			nftID: model.id,
			isCartChanged: isCartChanged,
			isFavoriteChanged: isFavoriteChanged
		)
	}
	
	func sendUpdateNotification(
		nftID: String,
		isCartChanged: Bool,
		isFavoriteChanged: Bool
	) {
		let payload = NFTUpdatePayload(
			id: nftID,
			screenID: screenID,
			updatesID: updatesID,
			isCartChanged: isCartChanged,
			isFavoriteChanged: isFavoriteChanged,
			fromObject: .sellerNFTs
		)
		print("SENT FROM: \(screenID)")
		NotificationCenter
			.default
			.post(
				name: .nftDidChange,
				object: nil,
				userInfo: [Constants.nftChangePayloadKey : payload]
			)
	}
	
	func loadNFTs() async throws {
		let unloadedIDs = nfts.filter(\.value.isNil).map(\.key)
		
		let favourites = await nftService.favouritesService.get()
		let order = await nftService.orderService.get()
		
		for id in unloadedIDs {
			let nft = try await nftService.loadNFT(id: id)
			let isFavorite = favourites.contains(id)
			let isInCart = order.contains(id)
			
			guard let index = nfts.firstIndex(where: { $0.key == id }) else { continue }
			nfts[index].value = .init(
				nft: nft,
				isFavorite: isFavorite,
				isInCart: isInCart
			)
		}
	}
}

// --- errors handlers ---
private extension SellerNFTsViewModel {
	func onNFTsError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(Constants.defaultAnimation) {
			showNFTsLoadingError = true
		}
	}
}

// --- polling lifecycle ---
private extension SellerNFTsViewModel {
	func startNFTsUpdatePolling()  {
		nftsUpdateTask = startSafeTaskPolling(
			pollingTask: nftsUpdateTask,
			operation: loadNFTs,
			clear: clearNFTsUpdateTask,
			onError: onNFTsError
		)
	}
	
	func clearNFTsUpdateTask() {
		nftsUpdateTask?.cancel()
		nftsUpdateTask = nil
	}

	func startSafeTaskPolling(
		pollingTask: Task<Void, Never>?,
		operation: @escaping () async throws -> Void,
		clear: @escaping () -> Void,
		onError: @escaping (Error) -> Void
	) -> Task<Void, Never> {
		if let pollingTask, !pollingTask.isCancelled {
			return pollingTask
		}
		
		let task = Task(priority: .utility) {
			defer { clear() }
			repeat {
				do {
					try await operation()
					try await Task.sleep(for: pollingInterval)
				} catch {
					onError(error)
				}
			} while !Task.isCancelled
		}
		
		return task
	}
}
