//
//  NFTVerticalCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

struct NFTVerticalCell: View {
	
	let model: NFTModelContainer?
	let didTapDetail: (NFTModelContainer) -> Void
	let likeAction: () -> Void
	let cartAction: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			NFTImageView(
				model: model?.nft,
				isFavourited: model?.isFavorite,
				layout: .my,
				likeAction: likeAction,
			)
			
			RatingPreview(rating: model?.nft.rating)
			
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					nameLabel
					costLabel
				}
				Spacer()
				cartButton
			}
		}
		.onTapGesture {
			if let model {
				didTapDetail(model)
			}
		}
	}
	
	private var nameLabel: some View {
		Text(model?.nft.name ?? NFTModel.mock.name)
			.foregroundStyle(.ypBlack)
			.lineLimit(Constants.nftNameLineLimit)
			.truncationMode(.tail)
			.font(.bold17)
			.applySkeleton(model)
	}
	
	private var costLabel: some View {
		Text(formatterPriceString)
			.foregroundStyle(.ypBlack)
			.font(.medium10)
			.applySkeleton(model)
	}
	
	private var cartButton: some View {
		Button(action: cartAction) {
			((model?.isInCart ?? false) ? Image.removeFromCart : Image.addToCart)
				.resizable()
				.font(.cartIcon)
				.foregroundStyle(.ypBlack)
				.frame(width: 40, height: 40)
		}
		.disabled(model == nil)
		.applySkeleton(model)
	}
	
	private var formatterPriceString: String {
		let string = "\(model?.nft.price ?? 99.99)"
		if let double = Double(string) {
			return String(format: "%.2f", double)
				.replacingOccurrences(of: ".", with: ",")
			+ " ETH"
		} else {
			return "0,0 ETH"
		}
	}
}

#if DEBUG
#Preview {
	@Previewable let columns = [
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top),
		GridItem(.flexible(), spacing: 9, alignment: .top)
	]
	
	ScrollView(.vertical){
		LazyVGrid(
			columns: columns,
			alignment: .center,
			spacing: 28
		) {
			ForEach(0..<10) { _ in
				NFTVerticalCell(
					model: .badImageURLMock,
					didTapDetail: {_ in},
					likeAction: {},
					cartAction: {}
				)
			}
		}
		.padding(.horizontal)
	}
}
#endif
