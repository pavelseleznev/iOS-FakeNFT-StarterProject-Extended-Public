//
//  ImageLoaderError.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//

import UIKit

enum ImageLoaderError: Error {
	case badURL
	case sessionError(String)
	case failedToLoad
}

actor ImageLoader {
	private let session: URLSession
	
	init() {
		let config = URLSessionConfiguration.default
		config.urlCache = .shared
		config.requestCachePolicy = .returnCacheDataElseLoad
		self.session = URLSession(configuration: config)
	}
	
	func load(from urlString: String) async -> UIImage? {
		guard let url = URL(string: urlString) else {
			return nil
		}
		
		do {
			let (data, _) = try await session.data(from: url)
			return UIImage(data: data)
		} catch {
			return nil
		}
	}
}
