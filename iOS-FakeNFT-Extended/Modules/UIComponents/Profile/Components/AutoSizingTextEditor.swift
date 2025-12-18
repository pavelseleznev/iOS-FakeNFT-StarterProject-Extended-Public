//
//  AutoSizingTextEditor.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/16/25.
//

import SwiftUI

struct AutoSizingTextEditor: View {
    @Binding var text: String
    var minHeight: CGFloat = 100
    var maxHeight: CGFloat = .infinity
    var font: Font = .system(size: 17)
    
    @State private var dynamicHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(text.isEmpty ? " " : text)
                .font(font)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
                .background(GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        let h = max(minHeight, min(proxy.size.height, maxHeight))
                        if abs(h - dynamicHeight) > 0.5 {
                            dynamicHeight = h
                        }
                    }
                    return Color.clear
                })
                .hidden()
            
            TextEditor(text: $text)
                .font(font)
                .frame(height: dynamicHeight)
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
        .onAppear {
            DispatchQueue.main.async {
                if dynamicHeight == 0 {
                    dynamicHeight = minHeight
                }
            }
        }
    }
}
