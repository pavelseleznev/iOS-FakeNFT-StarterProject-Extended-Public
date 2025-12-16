//
//  EditProfileFooter.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

struct EditProfileFooter: View {
    let isVisible: Bool
    let onSave: () -> Void

    var body: some View {
        VStack {
            Spacer()
            if isVisible {
                Button(action: onSave) {
                    Text("Сохранить")
                        .foregroundColor(.ypWhite)
                        .font(.bold17)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.ypBlack)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: isVisible)
            }
        }
    }
}
