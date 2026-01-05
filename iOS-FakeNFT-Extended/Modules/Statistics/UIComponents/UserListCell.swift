//
//  UserListCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

fileprivate let profileImageSize: CGFloat = 28

struct UserListCell: View, @MainActor Equatable {
	let model: UserListItemResponse
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.model.id == rhs.model.id
	}
	
	var body: some View {
		HStack {
			AsyncImageView(urlString: model.avatarURLString)
			
			Group {
				Text(model.name)
					.foregroundStyle(.ypBlack)
					.font(.bold22)
					.lineLimit(Constants.authorNameLineLimit)
				
				Spacer()
				
				Text("\(model.nftsIDs.count)")
					.foregroundStyle(.ypBlack)
					.font(.bold22)
					.padding(.leading)
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 16)
		.background(.ypLightGrey)
		.clipShape(RoundedRectangle(cornerRadius: 26))
		.overlay(BackgroundView())
	}
	
	private var gradientBackground: some View {
	   RoundedRectangle(cornerRadius: 26)
		   .fill(.ypLightGrey)
   }
}

fileprivate struct BackgroundView: View {
	var body: some View {
		RoundedRectangle(cornerRadius: 26)
			.stroke(
				LinearGradient(
					gradient: Gradient(
						colors: [
							.indigo,
							.ypBlackUniversal.opacity(0.2),
							.purple
						]
					),
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				).opacity(0.6),
				lineWidth: 0.5
			)
	}
}


fileprivate struct AsyncImageView: View {
	let urlString: String
	
	var body: some View {
		AsyncImageCached(urlString: urlString) { phase in
			switch phase {
			case .empty:
				Color.ypLightGrey
					.overlay {
						ProgressView()
					}
			case .loaded(let image):
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
			case .error:
				Image.profilePerson
					.resizable()
					.renderingMode(.template)
					.foregroundStyle(.ypGrayUniversal)
					.aspectRatio(contentMode: .fill)
			}
		}
		.frame(width: profileImageSize, height: profileImageSize)
		.clipShape(.circle)
	}
}

#if DEBUG
#Preview {
	@Previewable let monitor = NetworkMonitor.shared
	@Previewable @State var isShown = false
	
	List {
		if isShown {
			ForEach(0...100, id: \.self) { _ in
				UserListCell(model: .mock)
			}
			.listRowBackground(Color.clear)
			.listRowSeparator(.hidden)
		}
	}
	.listStyle(.plain)
	.scrollContentBackground(.hidden)
	.background(.ypWhite)
	.onAppear {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			isShown = true
		}
	}
}
#endif
