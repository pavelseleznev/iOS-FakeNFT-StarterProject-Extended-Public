//
//  Alerts.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

extension View {
	func applyRepeatableAlert(
		isPresented: Binding<Bool>,
		message: String,
		didTapRepeat: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresented) {
				Button("Отмена", role: .cancel) {}
				Button("Повторить", action: didTapRepeat)
			}
	}
	
	func applyExitAlert(
        isPresented: Binding<Bool>,
		message: String,
		didTapExit: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresented) {
				Button("Остаться", role: .cancel) {}
				Button("Выйти", action: didTapExit)
			}
	}
    
    func applyPhotoURLAlert(
        isPresented: Binding<Bool>,
        photoURL: Binding<String>,
        title: String = "Ccылка на фото",
        placeholder: String = "https://",
        onSave: @escaping (String) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        modifier(AlertPhotoURLModifier(
            isPresented: isPresented,
            photoURL: photoURL,
            title: title,
            placeholder: placeholder,
            onSave: onSave,
            onCancel: onCancel
        ))
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
		isPresented: $isPresented,
		message: "Не удалось получить данные",
		didTapRepeat: {}
	)
}

#Preview("Profile") {
	@Previewable @State var exitAlertPresented: Bool = false
    @Previewable @State var photoAlertPresented: Bool = false
    @Previewable @State var photoURLInput: String = ""
    
	ZStack {
		Color.ypWhite.ignoresSafeArea()
        
        VStack(spacing: 16) {
            Button("Perform profile exit") {
                exitAlertPresented.toggle()
            }
            
            Button("Perform profile photo change") {
                photoAlertPresented.toggle()
            }
        }
	}
	.applyExitAlert(
		        isPresented: $exitAlertPresented,
		message: "Уверены, что хотите выйти?",
		didTapExit: {}
	)
    
    .applyPhotoURLAlert(
        isPresented: $photoAlertPresented,
        photoURL: $photoURLInput,
        onSave: { _ in },
        onCancel: {}
    )
}
#endif
