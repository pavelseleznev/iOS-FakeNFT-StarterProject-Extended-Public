//
//  SplashViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 1/4/26.
//

import SwiftUI

@MainActor
@Observable
final class SplashViewModel {
    private let dependencies: AppContainer
    private let onComplete: () -> Void
    
    private(set) var dataLoadingErrorIsPresented = false
    
    init(
        appContainer: AppContainer,
        onComplete: @escaping () -> Void
    ) {
        self.dependencies = appContainer
        self.onComplete = onComplete
    }
}

// MARK: - SplashViewModel Extensions
// --- internal methods ---
extension SplashViewModel {
    func loadUserData() async {
        do {
            #warning("TODO: skip this by background long polling updates")
            
            try await dependencies.purchasedNFTsService.loadAndSave()
            try await dependencies.nftService.favouritesService.loadAndSave()
            try await dependencies.nftService.orderService.loadAndSave()
            try await dependencies.profileService.loadProfileAndSave()
            
            onComplete()
        } catch is CancellationError {
            print("\(#function) cancelled")
        } catch {
            print("\(#function) failed: \(error)")
        }
    }
    
    func dismissError(_ state: Bool) {
        dataLoadingErrorIsPresented = state
    }
}
