//
//  Array+Extensions.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 08.01.2026.
//


extension Array {
	func chunked(into size: Int) -> [[Element]] {
		guard size > 0 else { return [] }
		
		return stride(from: 0, to: count, by: size).map {
			Array(self[$0 ..< Swift.min($0 + size, count)])
		}
	}
}