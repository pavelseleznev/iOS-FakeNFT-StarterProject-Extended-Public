//
//  AutoSizingTextEditor.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/16/25.
//

import SwiftUI

fileprivate let maxHeight: CGFloat = 150

struct AutoSizingTextEditor: View {
    @Binding var text: String
	let placeholder: String
    
    var body: some View {
		ZStack(alignment: .topLeading) {
			Text(text.isEmpty ? placeholder : text)
				.font(.regular17)
				.foregroundColor(.clear)
				.padding(.horizontal, 5)
				.padding(.vertical, 8)
				.frame(maxWidth: .infinity, alignment: .leading)

            
            TextEditor(text: $text)
				.font(.regular17)
				.scrollContentBackground(.hidden)
			
			if text.isEmpty {
				Text(placeholder)
					.font(.regular17)
					.foregroundColor(.gray.opacity(0.5))
					.padding(.horizontal, 5)
					.padding(.vertical, 8)
					.allowsHitTesting(false)
			}
        }
		.frame(height: maxHeight)
		.padding(4)
		.padding(.horizontal, 8)
		.background(Color.ypLightGrey)
		.clipShape(RoundedRectangle(cornerRadius: 28))
		.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 10)
    }
}
