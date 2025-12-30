//
//  DataLoader.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import Observation

enum LoadingState: Equatable {
	case idle
	case fetching
	case error
}

@MainActor
@Observable
final class DataLoader {
	private(set) var loadingState: LoadingState = .idle
	private let cancelErrorsDscr = ["отменено", "cancelled"]
	
	func fetchData<T: Decodable>(
		_ operation: @escaping @Sendable () async throws -> T
	) async throws -> T {
		loadingState = .fetching
		
		do {
			defer {
				resetState()
			}
			return try await operation()
		} catch {
			let isCancellation = cancelErrorsDscr.contains(error.localizedDescription.lowercased()) ||
			error is CancellationError

			loadingState = isCancellation ? .idle : .error
			if isCancellation {
				throw CancellationError()
			} else {
				print("[DataLoader] fetch error: \(error.localizedDescription)")
				throw error
			}
		}
	}
	
	func resetState() {
		loadingState = .idle
	}
	
	func setLoadingStateFromWebsite(_ state: LoadingState) {
		self.loadingState = state
	}
}
