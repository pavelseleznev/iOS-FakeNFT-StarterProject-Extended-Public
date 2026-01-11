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
	
	@ObservationIgnored private var isForceUpdating = false
	@ObservationIgnored private var longPollingUpdateTask: Task<Void, Error>?
	@ObservationIgnored private(set) var isUpdating = false
	
	@ObservationIgnored private var currentPath = [Page]()
	@ObservationIgnored private var currentTab: Tab = .catalog
	
	init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}
}

// MARK: - BackgroundUpdater extensions
// --- navigation update ---
extension BackgroundUpdater {
	func didUpdateTab(_ newTab: Tab) {
		guard newTab != currentTab else { return }
		currentTab = newTab
		managePollingState()
	}
	func didUpdatePath(_ newPath: [Page]) {
		guard newPath != currentPath else { return }
		currentPath = newPath
		managePollingState()
	}
}

// MARK: - Logic & Config
private extension BackgroundUpdater {
	func managePollingState() {
		let config = currentConfig
		
		if config.interval == .paused {
			if !longPollingUpdateTask.isNil {
				stopLongPollingUpdates()
			}
		} else {
			if longPollingUpdateTask.isNil {
				startLongPollingUpdates()
			}
		}
	}
	
	struct UpdateTargets: OptionSet {
		let rawValue: Int
		static let profile    = UpdateTargets(rawValue: 1 << 0)
		static let cart       = UpdateTargets(rawValue: 1 << 1)
		static let currencies = UpdateTargets(rawValue: 1 << 2)
		static let favourites = UpdateTargets(rawValue: 1 << 3)
		static let purchased  = UpdateTargets(rawValue: 1 << 4)
		
		static let all: UpdateTargets = [
			.profile,
			.cart,
			.currencies,
			.favourites,
			.purchased
		]
		
		var requiresProfileRequest: Bool {
			!self.intersection([.profile, .favourites, .purchased]).isEmpty
		}
	}

	enum PollingInterval {
		case aggressive // 3s
		case normal     // 5s
		case relaxed    // 10s
		case paused     // ∞
		
		var duration: Duration {
			switch self {
			case .aggressive:
				.seconds(3)
			case .normal:
				.seconds(5)
			case .relaxed:
				.seconds(10)
			case .paused:
				.seconds(9999)
			}
		}
	}

	struct PollingConfig {
		let interval: PollingInterval
		let targets: UpdateTargets
		
		static let stopped = PollingConfig(interval: .paused, targets: [])
		static let standard = PollingConfig(interval: .normal, targets: .all)
		static let nfts = PollingConfig(
			interval: .aggressive,
			targets: [.favourites, .purchased]
		)
	}
	
	var currentConfig: PollingConfig {
		guard let lastPage = currentPath.last else {
			return .stopped
		}
		
		switch currentTab {
		case .cart:
			if case .tabView = lastPage {
				return PollingConfig(
					interval: .aggressive,
					targets: [.cart]
				)
			}
			
			if case .cart(let page) = lastPage {
				switch page {
				case .paymentMethodChoose:
					return PollingConfig(
						interval: .normal,
						targets: [.currencies]
					)
					
				case .successPayment:
					return .stopped
					
				@unknown default:
					return .standard
				}
			}
			
		case .catalog:
			if case .tabView = lastPage {
				return .stopped
			}
			
			if case .catalog(let page) = lastPage {
				switch page {
				case .catalogDetails:
					return PollingConfig.nfts
					
				@unknown default:
					return .standard
				}
			}
		case .profile:
			if case .tabView = lastPage {
				return PollingConfig(
					interval: .aggressive,
					targets: [.profile]
				)
			}
			
			if case .profile(let page) = lastPage {
				switch page {
				case .editProfile:
					return PollingConfig(
						interval: .normal,
						targets: [.profile]
					)
				
				case .favoriteNFTs, .myNFTs:
					return PollingConfig.nfts
				
				@unknown default:
					return .standard
				}
			}
			
		case .statistics:
			if case .tabView = lastPage {
				return .stopped
			}
			
			if case .statistics(let page) = lastPage {
				switch page {
				case .nftCollection:
					return PollingConfig.nfts
					
				case .profile:
					return .stopped
					
				@unknown default:
					return .standard
				}
			}
			
		@unknown default:
			return .standard
		}
		
		return .standard
	}
}

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
		
		defer {
			isForceUpdating = false
			startLongPollingUpdates()
		}
		
		guard await isAuthed() else {
			print("auth error, skipping...")
			return
		}
		
		do {
			try await performUpdates()
		} catch {
			print("\n\(#function) error: \(error.localizedDescription)")
		}
	}
}

// --- helpers ---
private extension BackgroundUpdater {
	func isAuthed() async -> Bool {
		await localStorage.value(forKey: Constants.isAuthedKey) ?? false
	}
	
	func runPolling() async throws {
		while !Task.isCancelled {
			let config = currentConfig
			
			if config.interval == .paused {
				break
			}
			
			guard !Task.isCancelled else { break }
			isUpdating = true
			
			do {
				try await performUpdates(with: config.targets)
			} catch is CancellationError {
				print("\n(#function) process killed by CancellationError")
				break
			} catch {
				print("\n\(#function) long polling update error: \(error.localizedDescription)")
			}
			
			isUpdating = false
			guard !Task.isCancelled else { break }
			try await Task
				.sleep(
					until: .now + config.interval.duration,
					tolerance: .seconds(0.5)
				)
		}
	}
	
	func performUpdates(with targets: UpdateTargets = .all) async throws {
		async let cartUpdate: Void = {
			if targets.contains(.cart) {
				try await appContainer.cartService.performUpdatesIfNeeded()
			}
		}()
		
		async let currenciesUpdate: Void = {
			if targets.contains(.currencies) {
				try await appContainer.currenciesService.performUpdatesIfNeeded()
			}
		}()
		
		async let profileUpdate: ProfileResponse? = {
			if targets.requiresProfileRequest {
				try await appContainer.profileService.performUpdatesIfNeeded()
			} else {
				nil
			}
		}()

		let (_, _, loadedProfile) = try await (
			cartUpdate,
			currenciesUpdate,
			profileUpdate
		)
		
		if let loadedProfile {
			if targets.contains(.favourites) {
				await appContainer.nftService.favouritesService
					.performUpdatesIfNeeded(with: loadedProfile.likes)
			}
			
			if targets.contains(.purchased) {
				await appContainer.purchasedNFTsService
					.performUpdatesIfNeeded(with: loadedProfile.nfts)
			}
		}
		print("\nBackgroundUpdater \(#function) done")
	}
}
