//
//  LRUImageCache.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//

import UIKit

@MainActor
final class LRUImageCache {
	private var cache = NSCache<NSString, UIImage>()
	private var recentOrder = [String]()
	private var keyToIndex = [String : Int]()
	private let maxCount: Int
	
	init(maxCount: Int = Constants.imageCacheCountLimit) {
		self.maxCount = maxCount
		cache.countLimit = maxCount * 2 // buffer
		cache.totalCostLimit = Constants.imageCacheTotalCostLimit
	}
	
	func set(_ image: UIImage, forKey key: String) {
		cache.setObject(image, forKey: NSString(string: key))
		
		if let index = keyToIndex[key] {
			recentOrder.remove(at: index)
			keyToIndex.removeValue(forKey: key)
		}
		
		
		recentOrder.append(key)
		keyToIndex[key] = recentOrder.count - 1
		
		trim()
	}
	
	func image(forKey key: String) -> UIImage? {
		if let index = keyToIndex[key] {
			recentOrder.remove(at: index)
			keyToIndex.removeValue(forKey: key)
			recentOrder.append(key)
			keyToIndex[key] = recentOrder.count - 1
		}
		
		return cache.object(forKey: NSString(string: key))
	}
	
	func removeOldest(_ count: Int = Constants.imageCacheOnMemoryWarningOldestCountRemoval) {
		let toRemove = min(count, recentOrder.count)
		
		for _ in 0..<toRemove {
			guard let oldestKey = recentOrder.first else { break }
			cache.removeObject(forKey: NSString(string: oldestKey))
			recentOrder.removeFirst()
			keyToIndex.removeValue(forKey: oldestKey)
		}
		updateIndices()
	}
	
	private func trim() {
		while recentOrder.count > maxCount {
			guard let oldestKey = recentOrder.first else { break }
			cache.removeObject(forKey: NSString(string: oldestKey))
			recentOrder.removeFirst()
			keyToIndex.removeValue(forKey: oldestKey)
		}
		updateIndices()
	}
	
	private func updateIndices() {
		for (index, key) in recentOrder.enumerated() {
			keyToIndex[key] = index
		}
	}
}
