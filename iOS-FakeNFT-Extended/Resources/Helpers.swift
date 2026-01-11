//
//  Helpers.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//


func comparatorPriority(_ str: String) -> UInt8 {
	guard let first = str.first else { return 2 }
	
	if first.isEn { return 0 }
	if first.isCyrillic { return 1 }
	
	return 2
}