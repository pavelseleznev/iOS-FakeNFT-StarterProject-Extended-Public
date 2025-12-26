//
//  Fonts.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.12.2025.
//

import SwiftUI

extension Font {
	static let design: Font.Design = .rounded
	
	// named fonts
	static let body = Font.system(
		size: 17,
		weight: .regular,
		design: design
	)
	
	// unnamed fonts
	static let bold22 = Font.system(
		size: 22,
		weight: .bold,
		design: design
	)

	static let regular13 = Font.system(
		size: 13,
		weight: .regular,
		design: design
	)
	
	static let regular15 = Font.system(
		size: 15,
		weight: .regular,
		design: design
	)
	
	static let regular17 = Font.system(
		size: 17,
		weight: .regular,
		design: design
	)
	
	static let bold17 = Font.system(
		size: 17,
		weight: .bold,
		design: design
	)

	static let medium10 = Font.system(
		size: 10,
		weight: .medium,
		design: design
	)
	
	// icons
	static let chevronLeftIcon = Font.system(
		size: 16,
		weight: .bold,
		design: design
	)
	
	static let chevronRightIcon = Font.system(
		size: 14,
		weight: .bold,
		design: design
	)
	
	static let editProfileIcon = Font.system(
		size: 26,
		weight: .bold,
		design: design
	)
	
	static let sortIcon = Font.system(
		size: 21,
		weight: .bold,
		design: design
	)
	
	static let startIcon = Font.system(
		size: 10,
		weight: .bold,
		design: design
	)
	
	static let starIcon = Font.system(
		size: 20,
		weight: .semibold,
		design: design
	)
	
	static let cartIcon = Font.system(
		size: 18.5,
		weight: .bold,
		design: design
	)
	
	static let xmarkIcon = Font.system(
		size: 15,
		weight: .bold,
		design: design
	)
}
