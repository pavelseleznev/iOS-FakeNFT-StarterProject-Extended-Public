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
		message: LocalizedStringResource,
		didTapRepeat: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresented) {
				Button(.cancel, role: .cancel) {}
				Button(.retry, action: didTapRepeat)
			}
	}
	
	func applyExitAlert(
		isPresented: Binding<Bool>,
		message: LocalizedStringResource,
		didTapExit: @escaping () -> Void
	) -> some View {
		self
			.alert(message, isPresented: isPresented) {
				Button(.cancel, role: .cancel) {}
				Button(.exit, action: didTapExit)
			}
	}
    
    func applyPhotoURLAlert(
        isPresented: Binding<Bool>,
        photoURL: Binding<String>,
        title: LocalizedStringResource = .linkToPhoto,
        placeholder: String = "https://",
        onSave: @escaping () -> Void,
    ) -> some View {
        modifier(AlertPhotoURLModifier(
            isPresented: isPresented,
            photoURL: photoURL,
            title: title,
            placeholder: placeholder,
            onSave: onSave
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
		message: .cantGetData,
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
		message: .sureToExit,
		didTapExit: {}
	)
    
    .applyPhotoURLAlert(
        isPresented: $photoAlertPresented,
        photoURL: $photoURLInput,
        onSave: {}
    )
}
#endif
