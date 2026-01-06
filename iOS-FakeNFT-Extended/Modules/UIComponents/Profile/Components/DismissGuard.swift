//
//  DismissGuard.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/16/25.
//

import SwiftUI

struct DismissGuard: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    let hasUnsavedChanges: Bool
    @Binding var showAlert: Bool
    let onConfirmDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if hasUnsavedChanges {
                            showAlert = true
                        } else {
                            onConfirmDismiss()
                            dismiss()
                        }
                    } label: {
                        Image.chevronLeft
                            .font(.chevronLeftIcon)
                    }
                    .tint(.ypBlack)
                }
            }
            .applyExitAlert(
                isPresented: $showAlert,
                message: "Уверены, что хотите выйти?",
                didTapExit: {
                    onConfirmDismiss()
                    dismiss()
                }
            )
    }
}

extension View {
    func dismissGuard(
        hasUnsavedChanges: Bool,
        showAlert: Binding<Bool>,
        onConfirmDismiss: @escaping () -> Void
    ) -> some View {
        modifier(
            DismissGuard(
                hasUnsavedChanges: hasUnsavedChanges,
                showAlert: showAlert,
                onConfirmDismiss: onConfirmDismiss
            )
        )
    }
}
