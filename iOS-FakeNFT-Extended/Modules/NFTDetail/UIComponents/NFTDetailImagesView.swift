//
//  NFTDetailImagesView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 26.12.2025.
//

import SwiftUI

fileprivate let maxScale: CGFloat = 3
fileprivate let minScale: CGFloat = 0.5
fileprivate let dismissScaleRatio: CGFloat = 0.1
fileprivate let spacing: CGFloat = 16
fileprivate let dissapearScaleThreshold: CGFloat = 1.08
fileprivate let dissapearVelocityThreshold: CGFloat = 2000
fileprivate let velocityHistoryCapacity: Int = 5
@MainActor fileprivate let imageStateTransition: AnyTransition = .opacity.animation(.easeInOut(duration: 0.5))

struct NFTDetailImagesView: View, @MainActor Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.selection == rhs.selection &&
		lhs.isFullScreen == rhs.isFullScreen
	}
	
	@State private var nftsImagesURLsStrings: [String : String]
	private let screenWidth: CGFloat
	private let isFavourite: Bool
	@Binding private var isFullScreen: Bool
	
	@State private var isDismissing = false
	@State private var scale: CGFloat = 1
	@State private var baseScale: CGFloat?
	@State private var selection: String?
	@State private var velocityHistory: [CGFloat] = {
		var array = [CGFloat]()
		array.reserveCapacity(velocityHistoryCapacity)
		return array
	}()
	
	private let imageCoordinateSpace: CoordinateSpace = .named("imageCoordinateSpace")
	private let wholeViewCoordinateSpace: CoordinateSpace = .named("wholeViewCoordinateSpace")
	
	init(
		nftsImagesURLsStrings: [String],
		screenWidth: CGFloat,
		isFavourite: Bool,
		isFullScreen: Binding<Bool>
	) {
		
		var _nftsImagesURLsStrings = [String : String]()
		nftsImagesURLsStrings.forEach {
			let id = UUID().uuidString
			_nftsImagesURLsStrings[$0, default: id] = id
		}
		
		selection = _nftsImagesURLsStrings.first?.value
		
		self.nftsImagesURLsStrings = _nftsImagesURLsStrings
		self.screenWidth = screenWidth
		self.isFavourite = isFavourite
		self._isFullScreen = isFullScreen
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			TabView(selection: $selection) {
				Group {
					if nftsImagesURLsStrings.isEmpty {
						LoadingShimmerPlaceholderView()
							.transition(.scale.combined(with: .opacity))
					} else {
						content
							.transition(.scale.combined(with: .opacity))
					}
				}
			}
			.simultaneousGesture(dismissGesture, isEnabled: isFullScreen)
			.scaleEffect(y: isDismissing ? scale : 1)
			.tabViewStyle(.page(indexDisplayMode: .never))
			.scrollDisabled(true)
			.background(
				LinearGradient(
					colors: [.purple, .indigo, .cyan],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.blur(radius: 50, opaque: true)
				.opacity(isFullScreen ? 0 : 0.6)
			)
			.clipShape(
				RoundedRectangle(
					cornerRadius: isFullScreen ? 0 : 40,
					style: .continuous
				)
			)
			.stretchy()
			.overlay(alignment: .bottom) {
				tabSelectorsView
			}
		}
		.animation(Constants.defaultAnimation, value: isDismissing)
		.animation(Constants.defaultAnimation, value: nftsImagesURLsStrings)
		.onChange(of: isFullScreen) { resetScale() }
		.simultaneousGesture(tapGestures)
	}
}

// MARK: - NFTDetailImagesView Extensions

// --- private subviews ---
private extension NFTDetailImagesView {
	var tabSelectorsView: some View {
		TabIndicatorsView(
			items: nftsImagesURLsStrings.map(\.value),
			selection: selection
		)
		.offset(y: spacing)
		.padding(.horizontal, spacing)
	}
	
	func loadingStateFromAsyncImagePhase(_ phase: AsyncImagePhase) -> LoadingState {
		switch phase {
		case .success:
			.idle
		case .failure:
			.error
		default:
			.fetching
		}
	}
	
	var content: some View {
		ForEach(
			Array(nftsImagesURLsStrings.enumerated()),
			id: \.element.key
		) { _, element in
			let imageURLString = element.key
			
			AsyncImageCached(urlString: imageURLString, transition: .opacity) { phase in
				switch phase {
				case .empty:
					LoadingView(loadingState: .fetching)
				case .loaded(let image):
					loadedImageView(image, isSelected: selection == element.value)
						.coordinateSpace(name: imageCoordinateSpace)
				case .error:
					LoadingView(loadingState: .error) {
						reloadImage(key: element.key, imageURLString: imageURLString)
					}
					.coordinateSpace(name: "loadingError")
				}
			}
			.tag(element.value)
			.id(element.value)
		}
		.coordinateSpace(name: wholeViewCoordinateSpace)
	}
	
	func loadedImageView(_ image: UIImage, isSelected: Bool) -> some View {
		ZStack {
			Color.ypWhite
			
			Image(uiImage: image)
				.resizable()
				.aspectRatio(1, contentMode: .fit)
				.scaleEffect(isSelected ? scale : 1)
				.onAppear {
					withAnimation(Constants.defaultAnimation) {
						scale = 1
					}
				}
		}
		.highPriorityGesture(magnificationGesture, isEnabled: isFullScreen)
	}
}

// --- private methods ---
private extension NFTDetailImagesView {
	func resetScale(checkForClippingBounds: Bool = false) {
		isDismissing = false
		
		withAnimation(Constants.defaultAnimation) {
			scale = checkForClippingBounds ? min(maxScale, max(minScale, scale)) : 1
			baseScale = nil
		}
	}
	
	func reloadImage(key: String, imageURLString: String) {
		let id = UUID().uuidString
		
		if nftsImagesURLsStrings[key, default: id] == selection {
			selection = id
		}
		nftsImagesURLsStrings[key, default: id] = id
	}
	
	func isVelocityThresholdReached(with rawVelocity: CGFloat) -> Bool {
		velocityHistory.append(rawVelocity)
		if velocityHistory.count == velocityHistoryCapacity { velocityHistory.removeFirst() }
		
		let historyItemsCount = CGFloat(velocityHistory.count)
		let velocity = velocityHistory.reduce(0, +) / (historyItemsCount == 0 ? 1 : historyItemsCount)

		return velocity >= dissapearVelocityThreshold
	}
	
	func isScaleThresholdReached(with scale: CGFloat) -> Bool {
		scale >= dissapearScaleThreshold
	}
}

// --- private gestures ---
private extension NFTDetailImagesView {
	var magnificationGesture: some Gesture {
		MagnificationGesture()
			.onChanged { value in
				if baseScale == nil {
					baseScale = scale
				}
				
				isDismissing = false
				scale = (baseScale ?? 1) * value
			}
			.onEnded { _ in
				isDismissing = false
				resetScale(checkForClippingBounds: true)
			}
	}
	
	var dismissGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				let isBottomToTopDrag = value.translation.height < 0
				guard isBottomToTopDrag else { return }
				
				if !isDismissing {
					resetScale()
				}
				
				let newScale = abs(value.translation.height / screenWidth * dismissScaleRatio) + 1
				
				if baseScale == nil {
					baseScale = scale
				}
				
				isDismissing = true
				scale = (baseScale ?? 1) * newScale
				
				let rawVelocty = value.velocity.height
				
				if
					rawVelocty < 0,
					isVelocityThresholdReached(with: rawVelocty) ||
					isScaleThresholdReached(with: scale)
				{
					withAnimation(Constants.defaultAnimation) {
						isFullScreen = false
					}
				}
			}
			.onEnded { _ in
				resetScale()
			}
	}
	
	var tapGestures: some Gesture {
		SimultaneousGesture(
			SpatialTapGesture(count: 2, coordinateSpace: imageCoordinateSpace)
				.onEnded { _ in
					withAnimation(Constants.defaultAnimation) {
						scale = 1
					}
				},
			SpatialTapGesture(count: 1, coordinateSpace: wholeViewCoordinateSpace)
				.onEnded { _ in
					withAnimation(Constants.defaultAnimation) {
						isFullScreen = true
					}
				}
		)
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	GeometryReader { geo in
		NavigationStack {
			NFTDetailImagesView(
				nftsImagesURLsStrings: [
					"https://noUrl.com",
					"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/1.png",
					"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/2.png",
					"https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Butter/3.png"
				],
				screenWidth: geo.size.width,
				isFavourite: false,
				isFullScreen: .constant(true)
			)
		}
	}
}
#endif
