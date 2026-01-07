import Foundation

protocol NFTServiceProtocol: Sendable {
    func loadNFT(id: String) async throws -> NFTResponse
	
	func addToFavourites(nftID id: String) async throws
	func removeFromFavourites(nftID id: String) async throws
	
	func addToCart(nftID id: String) async throws
	func removeFromCart(nftID id: String) async throws
	
	var favouritesService: NFTsIDsServiceProtocol { get }
	var orderService: NFTsIDsServiceProtocol { get }
}

actor NFTService: NFTServiceProtocol {
	let favouritesService: NFTsIDsServiceProtocol
	let orderService: NFTsIDsServiceProtocol
	private let loadNFT: (String) async throws -> NFTResponse

	init(
		favouritesService: NFTsIDsServiceProtocol,
		orderService: NFTsIDsServiceProtocol,
		loadNFT: @escaping (String) async throws -> NFTResponse
	) {
		self.favouritesService = favouritesService
		self.orderService = orderService
		self.loadNFT = loadNFT
	}
	
	@MainActor
	static var mock: Self {
		let api = ObservedNetworkClient()
		return Self(
			favouritesService: NFTsIDsService(
				api: api,
				kind: .favorites
			),
			orderService: NFTsIDsService(
				api: api,
				kind: .order
			),
			loadNFT: api.getNFT
		)
	}
}

// MARK: - NFTService Extensions
// --- methods ---
extension NFTService {
	func loadNFT(id: String) async throws -> NFTResponse {
		try await loadNFT(id)
	}
	
	func addToFavourites(nftID id: String) async throws {
		try await favouritesService.add(id)
	}
	func removeFromFavourites(nftID id: String) async throws {
		try await favouritesService.remove(id)
	}
	
	func addToCart(nftID id: String) async throws {
		try await orderService.add(id)
	}
	func removeFromCart(nftID id: String) async throws {
		try await orderService.remove(id)
	}
}
