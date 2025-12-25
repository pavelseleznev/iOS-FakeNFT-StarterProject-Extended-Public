//
//  AboutAuthorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct AboutAuthorView: View {
	let websiteURLString: String
	let onLoadingStateChange: (LoadingState) -> Void
	
	@State private var loadingState: LoadingState = .idle
	@Environment(\.colorScheme) private var theme
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
				.onChange(of: loadingState) {
					onLoadingStateChange(loadingState)
				}

			if let url = URL(string: websiteURLString) {
				WebViewRepresentable(
					url: url,
					loadingState: $loadingState,
					colorScheme: theme
				)
				.ignoresSafeArea(edges: .bottom)
			}
		}
	}
}

#Preview {
	NavigationStack {
		AboutAuthorView(
			websiteURLString: "https://www.google.com",
			onLoadingStateChange: {_ in}
		)
		.customNavigationBackButton(isTabView: false, backAction: {})
	}
}
