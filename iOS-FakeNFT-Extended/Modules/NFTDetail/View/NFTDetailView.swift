//
//  NFTDetailView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//

import SwiftUI

struct NFTDetailView: View {
	let nft: NFTModel
	
	@State private var images = [URL:UIImage]()
	@State private var nftImageScale: CGFloat = 1
	@State private var selection: URL?
	private let nftImageMaxScale: CGFloat = 3
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			TabView(selection: $selection) {
//				ForEach(Array(nft.images.enumerated()), id: \.offset) { index, url in
//					if let image = images[url] {
//						Image(uiImage: image)
//							.resizable()
//							.aspectRatio(contentMode: .fit)
//							.scaleEffect(nftImageScale)
//							.gesture(
//								MagnifyGesture()
//									.onChanged { value in
//										nftImageScale = value.magnification
//									}
//									.onEnded { value in
//										if nftImageScale > nftImageMaxScale {
//											withAnimation {
//												nftImageScale = nftImageMaxScale
//											}
//										}
//									}
//							)
//							.id(url)
//							.tag(url)
//					}
//				}
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.overlay(alignment: .bottom) {
				HStack {
					ForEach(Array(images.enumerated()), id: \.offset) { index, url in
						RoundedRectangle(cornerRadius: 12)
							.fill(selection == url.key ? .ypBlack : .ypGrayUniversal)
							.frame(width: .infinity, height: 4)
					}
				}
				.padding(.horizontal, 16)
			}
		}
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				Image.xmark
					.foregroundStyle(.ypBlack)
					.font(.xmarkIcon)
			}
		}
		.task {
			// load image from url
			withAnimation {
//				nft.images.forEach {
//					images[$0, default: .big] = .big
//				}
			}
		}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var isPresented = true
		Color.ypWhite.ignoresSafeArea()
			.sheet(isPresented: $isPresented) {
				NavigationStack {
					NFTDetailView(
						nft: .mock
					)
				}
			}
}
#endif
