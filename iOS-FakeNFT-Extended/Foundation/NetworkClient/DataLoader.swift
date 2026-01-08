//
//  DataLoader.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import Observation
import Foundation

enum LoadingState: Equatable {
	case idle
	case fetching
	case error
}

@MainActor
@Observable
final class DataLoader {
	private(set) var loadingState: LoadingState = .idle
	private let monitor = NetworkMonitor.shared
	
	func fetchData<T: Decodable>(
		function: String = #function,
		_ operation: @escaping @Sendable () async throws -> T
	) async throws -> T {
		guard monitor.isOnline else {
			throw NSError(domain: "No internet connection", code: 1)
		}
		
		loadingState = .fetching
		
		do {
			defer {
				resetState()
			}
			return try await operation()
		} catch let error where error is CancellationError ||
			error.localizedDescription.lowercased().contains("cancelled") ||
			error.localizedDescription.lowercased().contains("отменено")
		{
			print("\(function) was cancelled")
			loadingState = .idle
			throw CancellationError()
		} catch {
			print("[DataLoader] fetch error: \(error.localizedDescription)")
			throw error
		}
	}
	
	func resetState() {
		loadingState = .idle
	}
	
	func setLoadingStateFromWebsite(_ state: LoadingState) {
		self.loadingState = state
	}
}
