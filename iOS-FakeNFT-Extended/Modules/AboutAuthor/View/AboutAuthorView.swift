//
//  AboutAuthorView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct AboutAuthorVIew: View {
	@State private var isLoading = false
	@Environment(\.colorScheme) private var theme
	
	var body: some View {
		if let url = URL(string: "https://practicum.yandex.ru") {
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
		AboutAuthorVIew()
			.customNavigationBackButton(backAction: {})
	}
}
