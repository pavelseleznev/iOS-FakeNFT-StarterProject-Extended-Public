//
//  SplashView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var viewModel: SplashViewModel
    
    init(
        appContainer: AppContainer,
        onComplete: @escaping () -> Void
    ) {
        _viewModel = .init(
            initialValue: .init(appContainer: appContainer, onComplete: onComplete)
        )
    }
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			Image(.vector)
		}
        .task(priority: .userInitiated) {
            await viewModel.loadUserData()
        }
	}
}

#if DEBUG
#Preview("Splash") {
    @Previewable let api = ObservedNetworkClient()
    
    SplashView(
        appContainer: .mock,
        onComplete: {}
    )
}
#endif
