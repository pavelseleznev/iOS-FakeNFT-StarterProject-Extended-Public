//
//  PhotoURLAlertModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/16/25.
//

import SwiftUI

struct AlertPhotoURLModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var photoURL: String

    let title: String
    let placeholder: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @FocusState private var textFieldFocused: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented) // disable interaction under the alert

            if isPresented {
                // Dim background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 0) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                        .padding(.horizontal, 16)
                    VStack {
                        TextField(placeholder, text: $photoURL)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .focused($textFieldFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { textFieldFocused = true }
                            }
                    }
                    .padding(.top, 12)
                    .padding([.horizontal, .bottom], 16)

                    Divider()

                    HStack(spacing: 0) {
                        Button(action: {
                            photoURL = ""
                            withAnimation { isPresented = false }
                            onCancel()
                        }) {
                            Text("Отмена")
                                .frame(maxWidth: .infinity, maxHeight: 44)
                        }
                        .buttonStyle(AlertPhotoButtonStyle(isPrimary: false))

                        Divider()
                            .frame(width: 1, height: 44)

                        Button(action: {
                            let trimmed = photoURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            onSave(trimmed)
                            withAnimation { isPresented = false }
                        }) {
                            Text("Сохранить")
                                .frame(maxWidth: .infinity, maxHeight: 44)
                        }
                        .buttonStyle(AlertPhotoButtonStyle(isPrimary: true))
                        .disabled(photoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .frame(height: 44)
                }
                .frame(maxWidth: 270)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 8)
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
                .onTapGesture {}
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isPresented)
    }
}
