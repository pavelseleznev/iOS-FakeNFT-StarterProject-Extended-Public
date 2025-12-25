//
//  EmptyCartView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct EmptyCartView: View {
	var body: some View {
		VStack {
			Text(.shoppingCartIsEmpty)
				.font(.bold17)
				.foregroundStyle(.ypBlack)
			
			HStack(spacing: 12) {
				Text(.shoppingCartUpdate)
					.font(.regular13)
					.foregroundStyle(.ypGrayUniversal)
				
				ProgressView()
					.progressViewStyle(.circular)
			}
		}
	}
}
