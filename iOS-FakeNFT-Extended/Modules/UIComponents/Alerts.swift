//
//  Alerts.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

extension View {
	func applyRepeatableAlert(
		isPresneted: Binding<Bool>,
		message: LocalizedStringResource,
		didTapRepeat: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresneted) {
				Button(.cancel, role: .cancel) {}
				Button(.retry, action: didTapRepeat)
			}
	}
	
	func applyExitAlert(
		isPresneted: Binding<Bool>,
		message: LocalizedStringResource,
		didTapExit: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresneted) {
				Button(.cancel, role: .cancel) {}
				Button(.exit, action: didTapExit)
			}
	}
}

#if DEBUG
#Preview("Statistic") {
	@Previewable @State var isPresented: Bool = false
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button("Perform some fetch") {
			isPresented.toggle()
		}
	}
	.applyRepeatableAlert(
		isPresneted: $isPresented,
		message: .cantGetData,
		didTapRepeat: {}
	)
}

#Preview("Profile") {
	@Previewable @State var isPresented: Bool = false
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button("Perform profile exit") {
			isPresented.toggle()
		}
	}
	.applyExitAlert(
		isPresneted: $isPresented,
		message: .sureToExit,
		didTapExit: {}
	)
}
#endif
