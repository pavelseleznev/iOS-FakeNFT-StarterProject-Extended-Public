//
//  Page.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.12.2025.
//


enum Page: Hashable, Identifiable {
	case tabView
	case aboutAuthor
	
	var id: Self { self }
}