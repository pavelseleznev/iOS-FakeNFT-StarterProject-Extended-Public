//
//  NFTCostView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTCostView: View {
	let model: NFTResponse?
	let layout: NFTCellLayout
	
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			if layout != .compact {
				Text(.cost)
					.foregroundStyle(.ypBlack)
					.font(.regular13)
					.applySkeleton(model)
			}
			
			Text(String(format: "%.2f", model?.price ?? 99.99) + " ETH")
				.foregroundStyle(.ypBlack)
				.font(.regular13)
				.bold()
				.applySkeleton(model)
		}
	}
    
    private var showsLabel: Bool {
        layout == .my
    }
    
    private var costFont: Font {
        switch layout {
        case .my: .bold17
        case .compact: .regular15
        case .cart: .bold17
        }
    }
}
