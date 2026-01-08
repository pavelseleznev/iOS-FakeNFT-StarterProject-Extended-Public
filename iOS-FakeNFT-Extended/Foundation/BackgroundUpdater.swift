//
//  BackgroundUpdater.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.01.2026.
//

import Observation
import Foundation

@Observable
@MainActor
final class BackgroundUpdater {
	private let appContainer: AppContainer
	private let localStorage = StorageActor.shared
	
	private var isForceUpdating = false
	private var longPollingUpdateTask: Task<Void, Error>?
	private(set) var isUpdating = false
	
	init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}
}

// MARK: - BackgroundUpdater extensions
// --- methods
extension BackgroundUpdater {
	func startLongPollingUpdates() {
		guard longPollingUpdateTask.isNil else { return }
		
		longPollingUpdateTask = Task(priority: .utility) {
			guard await isAuthed(), !Task.isCancelled else {
				print("auth error, skipping...")
				stopLongPollingUpdates()
				return
			}
			
			print("\n\(#function) starting...")
			try await runPolling()
		}
	}
	
	func stopLongPollingUpdates() {
		print("\n\(#function) stopping...")
		longPollingUpdateTask?.cancel()
		longPollingUpdateTask = nil
	}
	
	func performForceUpdate() async {
		guard !isForceUpdating else { return }
		isForceUpdating = true
		
		stopLongPollingUpdates() // suspend
		
		guard await isAuthed() else {
			print("auth error, skipping...")
			return
		}
		
		do {
			try await performUpdates()
		} catch {
			print("\n\(#function) error: \(error.localizedDescription)")
		}
		
		isForceUpdating = false
		startLongPollingUpdates() // continue
	}
}

// --- helpers ---
private extension BackgroundUpdater {
	func isAuthed() async -> Bool {
		await localStorage.value(forKey: Constants.isAuthedKey) ?? false
	}
	
	func runPolling() async throws {
		while !Task.isCancelled {
			guard !Task.isCancelled else { break }
			
			isUpdating = true
			
			do {
				try await performUpdates()
			} catch is CancellationError {
				print("\n(#function) process killed by CancellationError")
				break
			} catch {
				print("\n\(#function) long polling update error: \(error.localizedDescription)")
			}
			
			isUpdating = false
			guard !Task.isCancelled else { break }
			try await Task.sleep(until: .now + .seconds(5), tolerance: .seconds(1))
		}
	}
	
	func performUpdates() async throws {
		async let cartUpdate: () = appContainer.cartService.performUpdatesIfNeeded()
		async let currenciesUpdate: () = appContainer.currenciesService.performUpdatesIfNeeded()
		async let profileUpdate = appContainer.profileService.performUpdatesIfNeeded()

		let (_, _, loadedProfile) = try await (cartUpdate, currenciesUpdate, profileUpdate)
		
		await appContainer.nftService.favouritesService
			.performUpdatesIfNeeded(with: loadedProfile.likes)
		await appContainer.purchasedNFTsService
			.performUpdatesIfNeeded(with: loadedProfile.nfts)
		print("\nBackgroundUpdater \(#function) done")
	}
}
