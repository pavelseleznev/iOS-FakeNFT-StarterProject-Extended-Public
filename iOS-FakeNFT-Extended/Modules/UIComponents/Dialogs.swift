//
//  BottomAlertContainer.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

extension View {
	func sortDialog(
		title: String,
		isPresented: Binding<Bool>,
		didTapCost: @escaping () -> Void,
		didTapRate: @escaping () -> Void,
		didTapName: @escaping () -> Void
	) -> some View {
		self
			.confirmationDialog(
				title,
				isPresented: isPresented,
				titleVisibility: .visible
			) {
				Button("По цене", action: didTapCost)
				Button("По рейтингу", action: didTapRate)
				Button("По названию", action: didTapName)
				Button("Закрыть", role: .cancel) {}
			}
	}
	
	func sortDialog(
		title: String,
		isPresented: Binding<Bool>,
		didTapName: @escaping () -> Void,
		didTapRate: @escaping () -> Void
	) -> some View {
		self
			.confirmationDialog(
				title,
				isPresented: isPresented,
				titleVisibility: .visible
			) {
				Button("По имени", action: didTapName)
				Button("По рейтингу", action: didTapRate)
				Button("Закрыть", role: .cancel) {}
			}
	}
	
	func sortDialog(
		title: String,
		isPresented: Binding<Bool>,
		didTapName: @escaping () -> Void,
		didTapNFTCount: @escaping () -> Void
	) -> some View {
		self
			.confirmationDialog(
				title,
				isPresented: isPresented,
				titleVisibility: .visible
			) {
				Button("По названию", action: didTapName)
				Button("По количеству NFT", action: didTapNFTCount)
				Button("Закрыть", role: .cancel) {}
			}
	}
	
	func photoActionDialog(
		title: String,
		isPresented: Binding<Bool>,
		didTapChangePhoto: @escaping () -> Void,
		didTapDeletePhoto: @escaping () -> Void
	) -> some View {
		self
			.confirmationDialog(title, isPresented: isPresented) {
				Button("Изменить фото", action: didTapChangePhoto)
				Button("Удалить фото", role: .destructive, action: didTapDeletePhoto)
				Button("Отмена", role: .cancel) {}
			}
	}
}

#if DEBUG
#Preview("Statistic") {
	@Previewable @State var isPresented: Bool = false
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button("Show statistic sort dialog") {
			isPresented.toggle()
		}
	}
	.sortDialog(
		title: "Сортировка",
		isPresented: $isPresented,
		didTapName: {},
		didTapRate: {}
	)
}

#Preview("Profile Sort") {
	@Previewable @State var isPresented: Bool = false
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button("Show profile sort dialog") {
			isPresented.toggle()
		}
	}
	.sortDialog(
		title: "Сортировка",
		isPresented: $isPresented,
		didTapCost: {},
		didTapRate: {},
		didTapName: {}
	)
}

#Preview("Catalog Sort") {
	@Previewable @State var isPresented: Bool = false
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button("Show catalog sort dialog") {
			isPresented.toggle()
		}
	}
	.sortDialog(
		title: "Сортировка",
		isPresented: $isPresented,
		didTapName: {},
		didTapNFTCount: {}
	)
}

#Preview("Profile Image") {
	@Previewable @State var isPresented: Bool = false
	ZStack {
		Color.ypWhite.ignoresSafeArea()
		Button("Show profile image actions dialog") {
			isPresented.toggle()
		}
	}
	.photoActionDialog(
		title: "Фото прпофиля",
		isPresented: $isPresented,
		didTapChangePhoto: {},
		didTapDeletePhoto: {}
	)
}
#endif
