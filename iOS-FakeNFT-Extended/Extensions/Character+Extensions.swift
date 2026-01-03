//
//  Character+Extensions.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//


extension Character {
	var isCyrillic: Bool {
		let cyrillicRanges: [ClosedRange<UInt32>] = [
			0x0410...0x044F,  // А-Я, а-я
		    0x0401...0x040C,  // Ё, Ѓ, Ќ и т.д.
		    0x0451...0x045C   // ё, ѓ, ќ и т.д.
		]
		
		guard let value = unicodeScalars.first?.value else { return false }
		return cyrillicRanges.contains { $0.contains(value) }
	}
	
	var isEn: Bool {
		let enRanges: [ClosedRange<UInt32>] = [
			65...90,  // A-Z
			97...122  // a-z
		]
		
		guard let value = unicodeScalars.first?.value else { return false }
		return enRanges.contains { $0.contains(value) }
	}
}