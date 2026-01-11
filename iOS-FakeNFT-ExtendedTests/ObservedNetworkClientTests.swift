//
//  ObservedNetworkClientTests.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 06.12.2025.
//

import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class ObservedNetworkClientTests: XCTestCase {
	private let api = DefaultNetworkClient()
	private lazy var sut = ObservedNetworkClient(api: api)
}

extension ObservedNetworkClientTests {
	func testGetCollections() async throws {
		let collections = try await sut.getCollections()
		print(collections)
		XCTAssertFalse(collections.isEmpty)
	}
	
	func testGetCollectionById() async throws {
		if let item = try await sut.getCollections().first {
			let _ = try await sut.getCollection(by: item.id)
		} else {
			XCTFail("Collection must not be empty")
		}
	}
}

extension ObservedNetworkClientTests {
	func testGetNFTs() async throws {
		let nfts = try await sut.getNFTs()
		XCTAssertFalse(nfts.isEmpty)
	}
	
	func testGetNFTByID() async throws {
		if let nft = try await sut.getNFTs().first {
			let _ = try await sut.getNFT(by: nft.id)
		} else {
			XCTFail("NFTs must not be empty")
		}
	}
}

extension ObservedNetworkClientTests {
	func testGetCurrencies() async throws {
		let currencies = try await sut.getCurrencies()
		XCTAssertFalse(currencies.isEmpty)
	}
	
	func testGetCurrencyByID() async throws {
		if let currency = try await sut.getCurrencies().first {
			let _ = try await sut.getCurrency(by: currency.id)
		} else {
			XCTFail("Currencies must not be empty")
		}
	}
}

extension ObservedNetworkClientTests {
	func testGetProfile() async throws {
		let _ = try await sut.getProfile()
	}
	
	func testUpdateProfile() async throws {
		let expectedName = "Студентус Практикумс Test"
		let response = try await sut.updateProfile(
			payload: .init(name: expectedName)
		)
		XCTAssertEqual(expectedName, response.name)
	}
}

extension ObservedNetworkClientTests {
	func testGetUsers() async throws {
		let users = try await sut.getUsers(page: 0, sortOption: .name)
		XCTAssertFalse(users.isEmpty)
	}
	
	func testGetUserByID() async throws {
		if let user = try await sut.getUsers(page: 0, sortOption: .name).first {
			let _ = try await sut.getUser(by: user.id)
		} else {
			XCTFail("Users must not be empty")
		}
	}
}

extension ObservedNetworkClientTests {
	func testPutOrderAndPay() async throws {
		var nftsToBuy = [String]()
		
		let nfts = try await sut.getNFTs()
		for index in 0..<3 {
			nftsToBuy.append(nfts[index].id)
		}
		
		let firstEmptyRepsonse = try await sut.putOrder(
			payload: .init(nfts: nil)
		)
		XCTAssertTrue(firstEmptyRepsonse.nftsIDs.isEmpty)
		
		let fullResponse = try await sut.putOrder(
			payload: .init(nfts: nftsToBuy)
		)
		XCTAssertEqual(nftsToBuy, fullResponse.nftsIDs)
		
		let secondEmptyRepsonse = try await sut.putOrder(
			payload: .init(nfts: nil)
		)
		XCTAssertTrue(secondEmptyRepsonse.nftsIDs.isEmpty)
	}
	
	func testGetOrder() async throws {
		let _ = try await sut.getOrder()
	}
}
