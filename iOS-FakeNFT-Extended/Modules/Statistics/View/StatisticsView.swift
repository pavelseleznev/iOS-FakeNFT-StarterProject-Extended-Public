//
//  StatisticsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct StatisticsView: View {
	let appContainer: AppContainer
	let push: (Page) -> Void
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			Text("Statistics")
				.font(.title)
				.bold()
		}
		.applyStatisticsSort(
			placement: .safeAreaTop,
			didTapName: {},
			didTapRate: {}
		)
	}
}
