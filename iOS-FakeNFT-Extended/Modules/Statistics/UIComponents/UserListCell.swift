//
//  UserListCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

fileprivate let profileImageSize: CGFloat = 36

struct UserListCell: View, @MainActor Equatable {
	let model: UserListItemResponse
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.model.id == rhs.model.id
	}
	
	var body: some View {
		HStack(spacing: 12) {
			AsyncImageView(urlString: model.avatarURLString)
			
			Group {
				VStack(alignment: .leading, spacing: 2) {
					Text(model.name)
						.foregroundStyle(.ypBlack)
						.font(.bold22)
						.lineLimit(Constants.statisticsAuthorCellNameLineLimit)
					RatingPreview(rating: Int(model.rating) ?? 0)
				}
				Spacer()
				
				Text("\(model.nftsIDs.count)")
					.foregroundStyle(.ypBlack)
					.font(.bold22)
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(.ypLightGrey)
		.clipShape(.capsule)
		.overlay(BackgroundView())
		.fixedSize(horizontal: false, vertical: true)
	}
}

fileprivate struct BackgroundView: View {
	var body: some View {
		RoundedRectangle(cornerRadius: 38)
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
