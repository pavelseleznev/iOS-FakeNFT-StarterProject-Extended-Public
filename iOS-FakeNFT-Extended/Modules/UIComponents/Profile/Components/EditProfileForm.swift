//
//  EditProfileForm.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import SwiftUI

struct EditProfileForm: View {
    @Binding var name: String
    @Binding var about: String
    @Binding var website: String
    @FocusState var focusedField: Field?

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Имя").font(.bold22)
                TextField("", text: $name)
                    .padding()
                    .font(.regular17)
                    .background(Color.ypLightGrey)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($focusedField, equals: .name)
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 8) {
                Text("Описание").font(.bold22)
                AutoSizingTextEditor(text: $about, minHeight: 100, font: .regular17)
                    .padding(8)
                    .background(Color.ypLightGrey)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .about)
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Сайт").font(.bold22)
                TextField("", text: $website)
                    .padding()
                    .font(.regular17)
                    .background(Color.ypLightGrey)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($focusedField, equals: .website)
            }
            .padding(.horizontal, 16)
        }
    }
}
