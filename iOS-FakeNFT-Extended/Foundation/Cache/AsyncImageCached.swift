//
//  AsyncImageCachedPhase.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//


import SwiftUI

enum AsyncImageCachedPhase: Equatable {
	case empty
	case loaded(UIImage)
	case error
}

struct AsyncImageCached<Content: View>: View {
	private let service = ImageLoadingWithCacheService.shared
	private let urlString: String
	private let placeholder: UIImage
	private let needsCache: Bool
	private let transition: AnyTransition
	private let animation: Animation
	
	@ViewBuilder private let content: (AsyncImageCachedPhase) -> Content
	
	@State private var phase: AsyncImageCachedPhase = .empty
	private let isLoadedFromCacheInstant: Bool
	
	init(
		needsCache: Bool = true,
		urlString: String,
		placeholder: UIImage = UIImage(systemName: "person.circle.fill") ?? .vector,
		transition: AnyTransition = .scale,
		animation: Animation = Constants.defaultAnimation,
		@ViewBuilder content: @escaping @MainActor (AsyncImageCachedPhase) -> Content,
	) {
		self.urlString = urlString
		self.placeholder = placeholder
		self.needsCache = needsCache
		self.transition = transition
		self.animation = animation
		
		self.content = content
		
		
		if
			!urlString.isEmpty,
			let image = service.getFromCache(urlString: urlString)
		{
			_phase = .init(initialValue: .loaded(image))
			isLoadedFromCacheInstant = true
		} else {
			isLoadedFromCacheInstant = false
		}
	}
	
	var body: some View {
		content(phase)
			.id(urlString)
			.transition(
				isLoadedFromCacheInstant ? .identity :
				.asymmetric(
					insertion: .scale.combined(with: .opacity),
					removal: .opacity
				).animation(isLoadedFromCacheInstant ? nil : animation)
			)
			.task(id: urlString, priority: .userInitiated) {
				guard !isLoadedFromCacheInstant else { return }
				
				guard
					!urlString.isEmpty,
					!Task.isCancelled,
					[.empty, .error].contains(phase)
				else {
					return
				}
				
				if let image = service.getFromCache(urlString: urlString) {
					phase = .loaded(image)
					return
				}
				
				phase = await loadImage()
			}
	}
	
	private func loadImage() async -> AsyncImageCachedPhase {
		guard !Task.isCancelled else { return .empty }
		
		let result = await service.loadImage(
			urlString: urlString,
			placeholder: placeholder,
			needsCache: needsCache
		)
		
		if let result {
			return .loaded(result)
		} else {
			return .error
		}
	}
}

extension AsyncImageCached: @MainActor Equatable {
	static func == (lhs: AsyncImageCached, rhs: AsyncImageCached) -> Bool {
		lhs.urlString == rhs.urlString && lhs.needsCache == rhs.needsCache
	}
}

#Preview {
//	ScrollView {
//		LazyVStack {
			List(1...1000, id: \.self) { _ in
				AsyncImageCached (
					urlString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS4K5dk2JcpotM-GLBsU6ZVwFSQkg0hCYFiUQ&s"
				) { phase in
					switch phase {
					case .empty:
						Color.ypLightGrey
							.overlay {
								ProgressView()
							}
					case .loaded(let image):
						Image(uiImage: image)
							.resizable()
					case .error:
						Image.profilePerson
							.resizable()
							.renderingMode(.template)
							.foregroundStyle(.ypGrayUniversal)
							.aspectRatio(contentMode: .fill)
					}
				}
				.frame(width: 300, height: 300)
				.clipShape(RoundedRectangle(cornerRadius: 12))
				.listRowBackground(Color.clear)
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
//		}
//	}
}
