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
	
	private let pollingInterval: Duration = .seconds(1)
	
	@ObservationIgnored private var authorUpdateTask: Task<Void, Never>?
	@ObservationIgnored private var nftsUpdateTask: Task<Void, Never>?
	@ObservationIgnored private var cartActionTask: Task<Void, Never>?
	@ObservationIgnored private var likeActionTask: Task<Void, Never>?
	
	private(set) var modelUpdateTriggerID = UUID()
	private var nfts = [String : NFTModelContainer?]()
	var showAuthorLoadingError = false
	var showNFTsLoadingError = false
	
	@inline(__always)
	var visibleNFTs: [NFTModelContainer?] {
		nfts
			.sorted {
				$0.key.localizedStandardCompare($1.key) == .orderedAscending
			}
			.map(\.value)
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
		clearCartActionTask()
		clearLikeActionTask()
	}
	
	func didTapCartButton(for model: NFTModelContainer?) {
		guard let model else { return }
		
		cartActionTask = changeModelState(
			model: model,
			updateTask: cartActionTask,
			clear: clearCartActionTask,
			invertInCartState: true,
			action: { @Sendable [weak self] in
				guard let self else { return }
				if model.isInCart {
					await nftService.removeFromCart(id: model.id)
				} else {
					await nftService.addToCart(id: model.id)
				}
			}
		)
	}
	
	func didTapLikeButton(for model: NFTModelContainer?) {
		guard let model else { return }
		
		likeActionTask = changeModelState(
			model: model,
			updateTask: likeActionTask,
			clear: clearLikeActionTask,
			invertFavouriteState: true,
			action: { @Sendable [weak self] in
				guard let self else { return }
				if model.isFavorite {
					await nftService.addToFavourite(id: model.id)
				} else {
					await nftService.removeFromFavourite(id: model.id)
				}
			}
		)
	}
}

// --- private methods ---
private extension SellerNFTsViewModel {
	func clearCartActionTask() {
		cartActionTask?.cancel()
		cartActionTask = nil
	}
	
	func clearLikeActionTask() {
		likeActionTask?.cancel()
		likeActionTask = nil
	}
	
	func changeModelState(
		model: NFTModelContainer,
		updateTask: Task<Void, Never>?,
		clear: @escaping () -> Void,
		invertFavouriteState: Bool = false,
		invertInCartState: Bool = false,
		action: @escaping () async -> Void
	) -> Task<Void, Never>? {
		guard updateTask == nil else { return updateTask }
		
		let task = Task(priority: .userInitiated) {
			defer { clear() }
			
			await action()
			
			guard let id = nfts.first(where: { $0.value == model })?.key else { return }
			
			nfts[id, default: nil] = .init(
				nft: model.nft,
				isFavorite: invertFavouriteState ? !model.isFavorite : model.isFavorite,
				isInCart: invertInCartState ? !model.isInCart : model.isInCart
			)
			
			withAnimation(.easeInOut(duration: 0.25)) {
				modelUpdateTriggerID = .init()
			}
		}
		
		return task
	}
	
	func switchLikeState(for model: NFTModelContainer, key id: String) {
		nfts[id] = .init(
			nft: model.nft,
			isFavorite: !model.isFavorite,
			isInCart: model.isInCart
		)
	}
	
	func switchCartState(for model: NFTModelContainer, key id: String) {
		nfts[id] = .init(
			nft: model.nft,
			isFavorite: model.isFavorite,
			isInCart: !model.isInCart
		)
	}
	
	func onNFTsError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(.easeInOut(duration: 0.15)) {
			showNFTsLoadingError = true
		}
	}
	
	func onAuthorError(_ error: Error) {
		guard !(error is CancellationError) else { return }
		withAnimation(.easeInOut(duration: 0.15)) {
			showAuthorLoadingError = true
		}
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
		
		let task = Task(priority: .background) {
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
	
	func loadNFTs() async throws {
		let unloadedIDs = nfts.filter(\.value.isNil).map(\.key)
		
		for id in unloadedIDs {
			let nft = try await nftService.loadNFT(id: id)
			let isFavorite = await nftService.isFavourite(id: id)
			let isInCart = await nftService.isInCart(id: id)
			
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
		nfts.reserveCapacity(newCapacity)
		
		newIDs.forEach {
			nfts[$0, default: nil] = nil
		}
		idsToRemove.forEach {
			nfts.removeValue(forKey: $0)
		}
	}
}
