//
//  AboutAuthorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct AboutAuthorView: View {
	let websiteURLString: String
	
	@State private var isLoading = false
	@Environment(\.colorScheme) private var theme
	
	var body: some View {
		if let url = URL(string: websiteURLString) {
			WebViewRepresentable(
				url: url,
				isLoading: $isLoading,
				colorScheme: theme
			)
			.ignoresSafeArea(edges: .bottom)
		}
	}
}

#Preview {
	NavigationStack {
		AboutAuthorView(websiteURLString: "https://practicum.yandex.ru")
			.customNavigationBackButton(backAction: {})
	}
}
