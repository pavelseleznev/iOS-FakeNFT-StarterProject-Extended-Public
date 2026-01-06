//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct CatalogView: View {
	let appContainer: AppContainer
	let push: (Page) -> Void
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			Button {
                push(.aboutAuthor(urlString: "https://practicum.yandex.ru"))
			} label: {
				Text("Catalog")
					.font(.title)
					.bold()
			}
		}
		.applyCatalogSort(
			placement: .safeAreaTop,
			didTapName: {
			},
			didTapNFTCount: {})
	}
}
