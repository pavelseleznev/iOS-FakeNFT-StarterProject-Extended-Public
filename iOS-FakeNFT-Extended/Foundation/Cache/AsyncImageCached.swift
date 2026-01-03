//
//  AsyncImageCachedPhase.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//


import SwiftUI

enum AsyncImageCachedPhase {
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
	@State private var loadingTask: Task<Void, Never>?
	
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
	}
	
	var body: some View {
		Group {
			switch phase {
			case .empty:
				content(.empty)
					.transition(transition.animation(animation))
			case .loaded(let image):
				content(.loaded(image))
					.transition(transition.animation(animation))
			case .error:
				content(.error)
					.transition(transition.animation(animation))
			}
		}
		.task(id: urlString, priority: .userInitiated) {
			guard !urlString.isEmpty else { return }
			await loadImage()
		}
	}
	
	private func loadImage() async {
		loadingTask?.cancel()
		
		let task = Task(priority: .userInitiated) { @MainActor in
			let image = await service.loadImage(
				urlString: urlString,
				placeholder: placeholder,
				needsCache: needsCache
			)
			
			guard !Task.isCancelled else { return }
			
			withAnimation(Constants.defaultAnimation) {
				if let image {
					phase = .loaded(image)
				} else {
					phase = .error
				}
			}
		}
		
		loadingTask = task
		await task.value
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
