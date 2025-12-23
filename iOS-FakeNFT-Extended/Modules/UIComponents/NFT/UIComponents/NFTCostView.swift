//
//  NFTCostView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 05.12.2025.
//

import SwiftUI

struct NFTCostView: View {
	
	let model: NFTModel
	let layout: NFTCellLayout
	
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			if layout != .compact {
				Text("Цена")
					.foregroundStyle(.ypBlack)
					.font(.regular13)
			}
			
			Text(model.cost)
				.foregroundStyle(.ypBlack)
				.font(costFont)
		}
	}
    
    private var showsLabel: Bool {
        layout == .my
    }
    
    private var costFont: Font {
        switch layout {
        case .my:
            return .bold17
        case .compact:
            return .regular15
        case .cart:
            return .bold17
        }
    }
}
