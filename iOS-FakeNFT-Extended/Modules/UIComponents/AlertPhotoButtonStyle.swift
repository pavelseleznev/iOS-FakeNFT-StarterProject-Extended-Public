//
//  AlertButtonStyle.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/16/25.
//

import SwiftUI

struct AlertPhotoButtonStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: isPrimary ? .semibold : .regular))
            .foregroundColor(isPrimary ? Color.accentColor : Color(UIColor.systemBlue))
            .background(Color.clear)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
