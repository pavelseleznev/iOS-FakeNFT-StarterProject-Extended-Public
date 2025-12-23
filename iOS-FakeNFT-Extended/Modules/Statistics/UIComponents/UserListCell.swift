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
				.lineLimit(1)
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
		Group {
			if
				!model.avatarURLString.isEmpty,
				let url = URL(string: model.avatarURLString)
			{
				AsyncImage(url: url) { image in
					image
						.resizable()
						.scaledToFit()
				} placeholder: {
					ProgressView()
						.progressViewStyle(.circular)
				}
			} else {
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
