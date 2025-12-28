//
//  SuccessPaymentView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 24.12.2025.
//

import SwiftUI

struct SuccessPaymentView: View {
	let backToCart: () -> Void
	
	var body: some View {
		ZStack(alignment: .bottom) {
			Color.ypWhite.ignoresSafeArea()
			
			VStack {
				Spacer()
				Image(.successPurchase)
				
				Text(.successPurchase)
					.font(.bold22)
					.foregroundStyle(.ypBlack)
					.multilineTextAlignment(.center)
				
				Spacer()
			}
			.padding(.horizontal)
			.padding(.horizontal)
			
			Button(action: backToCart) {
				HStack {
					Spacer()
					Text(.backToCart)
						.font(.bold17)
						.foregroundStyle(.ypWhite)
					Spacer()
				}
				.padding(19)
				.background(
					RoundedRectangle(cornerRadius: 16)
						.fill(.ypBlack)
				)
			}
			.padding()
		}
		.toolbar(.hidden)
	}
}

#if DEBUG
#Preview {
	NavigationStack {
		SuccessPaymentView(backToCart: {})
			.customNavigationBackButton(hasBackButton: true, backAction: {})
	}
}
#endif
