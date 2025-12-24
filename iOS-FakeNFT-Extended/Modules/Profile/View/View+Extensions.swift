//
//  View+Extensions.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/24/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
