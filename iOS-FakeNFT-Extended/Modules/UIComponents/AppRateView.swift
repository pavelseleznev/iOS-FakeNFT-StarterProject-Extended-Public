//
//  AppRateView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

struct AppRateView: View {
	@Binding var isPresented: Bool
	let didRateCalled: (Int) -> Void
	
	@State private var ratedStars: Int = 0
	private let maxStars: Int = 5
	
	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 18) {
				Image(.appIconSmall)
				
				rateAboutView
				
				Group {
					starsView
					rateButtonsView
				}
				.foregroundStyle(.accent)
			}
			.multilineTextAlignment(.center)
			.frame(width: geo.size.width * 0.6)
			.padding()
			.background(.regularMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 16))
			.position(
				x: geo.frame(in: .local).midX,
				y: geo.frame(in: .local).midY
			)
		}
		.animation(.easeInOut(duration: 0.15), value: isPresented)
		.animation(.easeInOut(duration: 0.15), value: ratedStars)
	}
	
	private func close() {
		isPresented = false
	}
	
	private var rateButtonsView: some View {
		HStack {
			Button(.notNow, action: close)
			if ratedStars > 0 {
				Spacer()
				Button(.rate) {
					didRateCalled(ratedStars)
					close()
				}
				.bold()
			}
		}
		.padding(.horizontal)
	}
	
	private var rateAboutView: some View {
		Group {
			VStack(spacing: 8) {
				Text(.rateTitle)
					.font(.bold17)
				
				Text(.rateBody)
					.font(.regular15)
			}
		}
		.foregroundStyle(.ypBlack)
	}
	
	private var starsView: some View {
		HStack(spacing: 15) {
			ForEach(0..<maxStars, id: \.self) { id in
				(id < ratedStars ? Image.starFill : Image.star)
					.font(.starIcon)
					.foregroundStyle(.accent)
					.onTapGesture {
						ratedStars = id + 1
					}
			}
		}
	}
}

extension View {
	func applyAppRatingView(
		isPresented: Binding<Bool>,
		didRateCalled: @escaping (Int) -> Void
	) -> some View {
		self
			.opacity(isPresented.wrappedValue ? 0.5 : 1)
			.allowsHitTesting(!isPresented.wrappedValue)
			.overlay {
				if isPresented.wrappedValue {
					AppRateView(
						isPresented: isPresented,
						didRateCalled: didRateCalled
					)
					.transition(.blurReplace)
					.transition(.opacity)
				}
			}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var isPresented = false
	
	ZStack {
		Image(.big)
			.resizable()
			.scaledToFill()
			.ignoresSafeArea()
			.applyAppRatingView(
				isPresented: $isPresented,
				didRateCalled: {_ in}
			)
	}
	.onAppear {
		withAnimation(.easeInOut(duration: 0.15).delay(1)) {
			isPresented = true
		}
	}
}
#endif
