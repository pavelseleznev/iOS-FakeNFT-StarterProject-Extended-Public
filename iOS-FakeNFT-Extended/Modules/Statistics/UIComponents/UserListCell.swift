//
//  UserListCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.12.2025.
//

import SwiftUI
import Kingfisher

struct UserListCell: View {
	let model: UserListItemResponse
	let counter: Int
	
	var body: some View {
		HStack(spacing: 16) {
			Text("\(counter + 1)")
				.foregroundStyle(.ypBlack)
				.font(.regular15)
			
			HStack(spacing: 8) {
				profileImage
				
				Group {
					Text(model.name)
					
					Spacer()
					
					Text("\(model.nftsIDs.count)")
				}
				.foregroundStyle(.ypBlack)
				.font(.bold22)
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
			if let url = URL(string: model.avatarURLString) {
				KFImage(url)
					.resizable()
					.scaledToFit()
			} else {
				Image.profilePerson
					.resizable()
					.scaledToFit()
			}
		}
		.frame(width: 28, height: 28)
		.clipShape(Circle())
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
}
#endif
