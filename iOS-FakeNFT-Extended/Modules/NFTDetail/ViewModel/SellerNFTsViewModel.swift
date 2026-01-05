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
	@ObservationIgnored
	private let screenID = UUID()
	
	private let pollingInterval: Duration = .seconds(1)
	
	@ObservationIgnored private var authorUpdateTask: Task<Void, Never>?
	@ObservationIgnored private var nftsUpdateTask: Task<Void, Never>?
	
	private(set) var modelUpdateTriggerID = UUID()
	private var nfts = [String : NFTModelContainer?]()
	var showAuthorLoadingError = false
	var showNFTsLoadingError = false
	
	var visibleNFTs: [Dictionary<String, NFTModelContainer?>.Element] {
		nfts
			.sorted {
				$0.key.localizedStandardCompare($1.key) == .orderedAscending
			}
	}
	
	init(
		authorID: String,
		excludingNFTID: String,
		nftService: NFTServiceProtocol,
		loadAuthor: @escaping (String) async throws -> UserListItemResponse,
	) {
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
		startAuthorUpdatePolling()
		startNFTsUpdatePolling()
	}
	
	func clearAllTasks() {
		clearNFTsUpdateTask()
		clearAuthorUpdateTask()
	}
	
	func didTapCartButton(for model: NFTModelContainer?) {
		guard let model else { return }
		changeModelState(model: model, isCartChanged: true)
	}
	
	func didTapLikeButton(for model: NFTModelContainer?) {
		guard let model else { return }
		changeModelState(model: model, isFavoriteChanged: true)
	}
	
	func handleNFTChangeNotification(notification: Notification) {
		if
			let payload = notification.userInfo?[Constants.nftChangePayloadKey] as? NFTUpdatePayload,
			payload.screenID != screenID,
			payload.hasChanges,
			let model = nfts[payload.id]
		{
			if payload.isCartChanged {
				didTapCartButton(for: model)
			}
			
			if payload.isFavoriteChanged {
				didTapLikeButton(for: model)
			}
		}
	}
}

// --- private methods ---
private extension SellerNFTsViewModel {
	func changeModelState(
		model: NFTModelContainer,
		isFavoriteChanged: Bool = false,
		isCartChanged: Bool = false
	) {
		nfts[model.id] = .init(
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
			isCartChanged: isCartChanged,
			isFavoriteChanged: isFavoriteChanged,
			fromObject: .sellerNFTs
		)
		
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
			
			nfts[id] = .init(
				nft: nft,
				isFavorite: isFavorite,
				isInCart: isInCart
			)
		}
	}
	
	func updateAuthor() async throws {
		let author = try await loadAuthor(authorID)
		
		let loadedIDs: Set<String> = {
			var rawLoadedIDs = Set(author.nftsIDs)
			rawLoadedIDs.remove(excludingNFTID)
			return rawLoadedIDs
		}()
		let oldIDs = Set(nfts.keys)
		
		let newIDs = loadedIDs.subtracting(oldIDs)
		let idsToRemove = oldIDs.subtracting(loadedIDs)
		
		let newCapacity = oldIDs.count - idsToRemove.count + newIDs.count
		guard newCapacity != oldIDs.count else { return }
		nfts.reserveCapacity(newCapacity)
		
		newIDs.forEach {
			nfts[$0, default: nil] = nil
		}
		idsToRemove.forEach {
			nfts.removeValue(forKey: $0)
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
	
	func onAuthorError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(Constants.defaultAnimation) {
			showAuthorLoadingError = true
		}
	}
}

// --- polling lifecycle ---
private extension SellerNFTsViewModel {
	func startAuthorUpdatePolling() {
		authorUpdateTask = startSafeTaskPolling(
			pollingTask: authorUpdateTask,
			operation: updateAuthor,
			clear: clearAuthorUpdateTask,
			onError: onAuthorError
		)
	}
	
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
	
	func clearAuthorUpdateTask() {
		authorUpdateTask?.cancel()
		authorUpdateTask = nil
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
