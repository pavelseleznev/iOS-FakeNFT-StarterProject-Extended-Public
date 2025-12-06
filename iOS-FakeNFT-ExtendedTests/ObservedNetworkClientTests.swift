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
	
	func testGetNFTById() async throws {
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
		let _ = try await sut.updateProfile(
			payload: .init(
				name: "Студентус Практикумс Test",
				description: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100 NFT, и еще больше — на моём сайте.",
				avatar: "https://photo.bank/1.png",
				website: "https://practicum.yandex.ru",
				likes: []
			)
		)
	}
}

extension ObservedNetworkClientTests {
	func testGetUsers() async throws {
		let users = try await sut.getUsers()
		XCTAssertFalse(users.isEmpty)
	}
	
	func testGetUserByID() async throws {
		if let user = try await sut.getUsers().first {
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
		for index in 0..<2 {
			nftsToBuy.append(nfts[index].id)
		}
		
		let firstEmptyRepsonse = try await sut.putOrderAndPay(
			payload: ["null"]
		)
		XCTAssertTrue(firstEmptyRepsonse.nftsIDs.isEmpty)
		
		print("\n\n\n", nftsToBuy, "\n\n\n")
		let fullResponse = try await sut.putOrderAndPay(
			payload: nftsToBuy
		)
		print("\n\n\n", fullResponse.nftsIDs, "\n\n", nftsToBuy, "\n\n\n")
		XCTAssertEqual(nftsToBuy, fullResponse.nftsIDs)
		
		let secondEmptyRepsonse = try await sut.putOrderAndPay(
			payload: ["null"]
		)
		XCTAssertTrue(secondEmptyRepsonse.nftsIDs.isEmpty)
	}
	
	func testGetOrder() async throws {
		let _ = try await sut.getOrder()
	}
	
	private func resetCart() async throws {
		let _ = try await sut.putOrderAndPay(payload: ["null"])
	}
}
