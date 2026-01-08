//
//  EditProfileForm.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

#warning("TODO: Loalize all fields")
struct EditProfileForm: View {
    @Binding var name: String
    @Binding var about: String
    @Binding var website: String

    var body: some View {
        VStack(spacing: 24) {
			FormView(title: "Имя", placeholder: "Написать...", text: $name)

            VStack(alignment: .leading, spacing: 8) {
                Text("Описание")
					.font(.bold22)
					.padding(.leading)
				
				AutoSizingTextEditor(
					text: $about,
					placeholder: "Написать..."
				)
            }
			
			FormView(
				title: "Сайт",
				placeholder: "Написать...",
				text: $website
			)
        }
		.padding(.horizontal, 16)
    }
}

// MARK: - Helper
fileprivate struct FormView: View {
	let title: String
	let placeholder: String
	@Binding var text: String
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.bold22)
				.padding(.leading)
			
			TextField(placeholder, text: $text)
				.padding()
				.font(.regular17)
				.background(Color.ypLightGrey)
				.clipShape(.capsule)
				.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 10)
		}
	}
}

// MARK: - Preview
#Preview("Full content") {
	Color.ypWhite.ignoresSafeArea()
		.overlay {
			EditProfileForm(
				name: .constant("GAGAGAGAGA"),
				about: .constant("Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100 NFT, и еще больше — на моём сайте…Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100 NFT, и еще больше — на моём сайте…Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100 NFT, и еще больше — на моём сайте…Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100 NFT, и еще больше — на моём сайте…"),
				website: .constant("GAGAGAGAG")
			)
		}
}

#Preview("Empty content") {
	Color.ypWhite.ignoresSafeArea()
		.overlay {
			EditProfileForm(
				name: .constant(""),
				about: .constant(""),
				website: .constant("")
			)
		}
}
