//
//  NFTDetailGoToSelleSiteButtonView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import SwiftUI

struct NFTDetailGoToSellerSiteButtonView: View {
	let action: () -> Void
	let spacing: CGFloat
	
	var body: some View {
		Button(action: action) {
			Text(.goToUserSite)
		}
		.padding(.horizontal)
		.padding(.top, -spacing / 2)
		.nftButtonStyle(filled: false)
	}
}
