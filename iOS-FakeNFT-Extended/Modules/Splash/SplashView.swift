//
//  SplashView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.12.2025.
//

import SwiftUI

struct SplashView: View {
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			Image(.vector)
		}
	}
}

#if DEBUG
#Preview {
	SplashView()
}
#endif
