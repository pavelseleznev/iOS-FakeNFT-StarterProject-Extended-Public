//
//  NavigationBackButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

extension View {
	func customNavigationBackButton(
		hasBackButton: Bool,
		backAction: @escaping () -> Void
	) -> some View {
		self
			.navigationBarBackButtonHidden()
			.toolbar {
				if !hasBackButton {
					ToolbarItem(placement: .cancellationAction) {
						Button(action: backAction) {
							Image.chevronLeft
								.font(.chevronLeftIcon)
								.padding([.vertical, .trailing], 8)
						}
						.tint(.ypBlack)
					}
				}
			}
	}
}
