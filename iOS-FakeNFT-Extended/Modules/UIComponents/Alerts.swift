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
		message: String,
		didTapRepeat: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresneted) {
				Button("Отмена", role: .cancel) {}
				Button("Повторить", action: didTapRepeat)
			}
	}
	
	func applyExitAlert(
		isPresneted: Binding<Bool>,
		message: String,
		didTapExit: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresneted) {
				Button("Отмена", role: .cancel) {}
				Button("Выйти", action: didTapExit)
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
		message: "Не удалось получить данные",
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
		message: "Уверены, что хотите выйти?",
		didTapExit: {}
	)
}
#endif
