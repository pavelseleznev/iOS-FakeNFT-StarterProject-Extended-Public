//
//  ToolbarSortButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct ToolbarSortButton: View {
	let action: () -> Void
	var body: some View {
		Button(action: action) {
			Image.sort
				.foregroundStyle(.ypBlack)
				.font(.sortIcon)
		}
	}
}
