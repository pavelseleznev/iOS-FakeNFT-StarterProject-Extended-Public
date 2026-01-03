//
//  ImageCacherService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 31.12.2025.
//

import UIKit
import Combine
import Network

@MainActor
final class ImageLoadingWithCacheService {
	static let shared = ImageLoadingWithCacheService()
	
	private let cache = LRUImageCache(maxCount: Constants.imageCacheCountLimit)
	private let loader: ImageLoader
	private let monitor = NetworkMonitor.shared
	private var cancellables = Set<AnyCancellable>()
	
	private init() {
		loader = ImageLoader()
		
		NotificationCenter
			.default
			.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
			.sink { [weak self] _ in
				self?.cache.removeOldest()
			}
			.store(in: &cancellables)
	}
	
	func loadImage(
		urlString: String,
		placeholder: UIImage,
		needsCache: Bool
	) async -> UIImage? {
		if needsCache, let cached = cache.image(forKey: urlString) {
			return cached
		}
		
		guard
			monitor.isOnline,
			let host = URL(string: urlString)?.host(),
			!host.contains("ipfs") && !host.contains("cloudflare")
		else {
			if (urlString.split(separator: "/").first?.contains("ipfs") ?? false) && needsCache {
				cache.set(placeholder, forKey: urlString)
			}
			
			return nil
		}
		
		if let image = await loader.load(from: urlString) {
			if needsCache {
				cache.set(image, forKey: urlString)
			}
			
			return image
		}
		
		return nil
	}
}
