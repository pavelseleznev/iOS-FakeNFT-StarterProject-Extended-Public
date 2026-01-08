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
	
	@Environment(\.colorScheme) private var theme
	
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
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(theme == .dark ? .bar : .regular)
					.shadow(color: .ypBlackUniversal.opacity(0.2), radius: 10)
					.background(
						LinearGradient(
							colors: [
								.purple,
								.ypRedUniversal,
								.ypYellowUniversal
							],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
						.blur(radius: 30)
						.opacity(theme == .dark ? 0.2 : 0.4)
					)
			)
			.position(
				x: geo.frame(in: .local).midX,
				y: geo.frame(in: .local).midY
			)
		}
		.animation(Constants.defaultAnimation, value: isPresented)
		.animation(Constants.defaultAnimation, value: ratedStars)
		.transition(.scale.combined(with: .opacity))
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
			ForEach(0..<Constants.maxRatingStars, id: \.self) { id in
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
			.blur(radius: isPresented.wrappedValue ? 2 : 0)
			.opacity(isPresented.wrappedValue ? 0.7 : 1)
			.allowsHitTesting(!isPresented.wrappedValue)
			.overlay {
				if isPresented.wrappedValue {
					AppRateView(
						isPresented: isPresented,
						didRateCalled: didRateCalled
					)
				}
			}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var isPresented = false
	
	ZStack {
		Color.ypWhite
			.ignoresSafeArea()
			.applyAppRatingView(
				isPresented: $isPresented,
				didRateCalled: {_ in}
			)
	}
	.onAppear {
		withAnimation(Constants.defaultAnimation.delay(1)) {
			isPresented = true
		}
	}
}
#endif
