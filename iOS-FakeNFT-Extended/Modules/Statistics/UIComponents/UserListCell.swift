//
//  UserListCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI

struct UserListCell: View {
	let model: UserListItemResponse
	let counter: Int
	
	var body: some View {
		HStack {
			Text("\(counter + 1)")
				.foregroundStyle(.ypBlack)
				.frame(width: 35)
				.font(.regular15)
				.multilineTextAlignment(.leading)
			
			HStack {
				profileImage
				
				Group {
					Text(model.name)
					
					Spacer()
					
					Text("\(model.nftsIDs.count)")
				}
				.foregroundStyle(.ypBlack)
				.font(.bold22)
				.lineLimit(Constants.authorNameLineLimit)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 26)
			.background {
				RoundedRectangle(cornerRadius: 12)
					.fill(.ypLightGrey)
			}
		}
	}
	
	private var profileImage: some View {
		AsyncImage(
			url: URL(string: model.avatarURLString),
			transaction: .init(animation: Constants.defaultAnimation)
		) { phase in
			switch phase {
			case .empty:
				ProgressView()
					.progressViewStyle(.circular)
			case .success(let image):
				image
					.resizable()
					.scaledToFit()
			default:
				Image.profilePerson
					.resizable()
					.scaledToFit()
			}
		}
		.frame(width: 28, height: 28)
		.clipShape(.circle)
	}
}

#if DEBUG
#Preview {
	VStack {
		UserListCell(model: .mock, counter: 0)
		UserListCell(model: .mock, counter: 1)
		UserListCell(model: .mock, counter: 2)
		UserListCell(model: .mock, counter: 3)
	}
	.background(.ypWhite)
}
#endif
