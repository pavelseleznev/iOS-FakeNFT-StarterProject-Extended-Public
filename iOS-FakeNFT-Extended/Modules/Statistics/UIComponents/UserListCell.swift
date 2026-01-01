//
//  UserListCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

fileprivate let profileImageSize: CGFloat = 28

struct UserListCell: View {
	let model: UserListItemResponse
	
	var body: some View {
		HStack {
			profileImage
			
			Group {
				Text(model.name)
				
				Spacer()
				
				Text("\(model.nftsIDs.count)")
					.padding(.leading)
			}
			.foregroundStyle(.ypBlack)
			.font(.bold22)
			.lineLimit(Constants.authorNameLineLimit)
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 16)
		.background(
			RoundedRectangle(cornerRadius: 26)
				.stroke(
					LinearGradient(
						stops: [
							.init(color: .indigo, location: 0),
							.init(color: .ypLightGrey, location: 0.1),
							.init(color: .ypLightGrey, location: 0.9),
							.init(color: .purple, location: 1),
						],
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					),
					lineWidth: 0.5
				)
				.fill(.ypLightGrey)
		)
		.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 4)
	}
	
	private var profileImage: some View {
		AsyncImageCached (urlString: model.avatarURLString) { phase in
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
	
	ScrollView(.vertical) {
		LazyVStack(spacing: 16) {
			if isShown {
				ForEach(0...100, id: \.self) { _ in
					UserListCell(model: .mock)
				}
			}
		}
		.safeAreaPadding(.horizontal)
	}
	.background(.ypWhite)
	.onAppear {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			isShown = true
		}
	}
}
#endif
