import Foundation

protocol NFTServiceProtocol: Sendable {
	func didLoadUserData(
		likes: [String],
		purchased: [String],
		cart: [String]
	) async
	
    func loadNFT(id: String) async throws -> NFTResponse
	
	func didPurchase(ids: [String]) async
	
	func addToCart(id: String) async
	func removeFromCart(id: String) async
	func isInCart(id: String) async -> Bool
	func clearCart() async
	
	func isFavourite(id: String) async -> Bool
	func removeFromFavourite(id: String) async
	func addToFavourite(id: String) async
	
	func getAllFavourites() async -> [String]
	func getAllPurchased() async -> [String]
	func getAllCart() async -> [String]
}

actor NFTService: NFTServiceProtocol {
	private let api: ObservedNetworkClient
	private let storage: NFTStorageProtocol

	init(api: ObservedNetworkClient, storage: NFTStorageProtocol) {
        self.storage = storage
        self.api = api
    }
}

// MARK: - getters
extension NFTService {
	func getAllFavourites() async -> [String] {
		Array(await storage.getFavourites())
	}
	
	func getAllPurchased() async -> [String] {
		Array(await storage.getPurchased())
	}
	
	func getAllCart() async -> [String] {
		Array(await storage.getCart())
	}
}

// MARK: - helpers
extension NFTService {
	func loadNFT(id: String) async throws -> NFTResponse {
		let nft = try await api.getNFT(by: id)
		return nft
	}
	
	func didLoadUserData(
		likes: [String],
		purchased: [String],
		cart: [String]
	) async {
		for id in likes {
			await storage.addToFavourites(id: id)
		}
		
		for id in purchased {
			await storage.addToPurchased(id: id)
		}
		
		for id in cart {
			await storage.addToCart(id: id)
		}
	}
}

// MARK: - cart
extension NFTService {
	func clearCart() async {
		await storage.clearCart()
		do {
			try await api.putOrder(payload: .init(nfts: nil))
		} catch {
			guard !(error is CancellationError) else { return }
			print(error.localizedDescription)
		}
	}
	
	func didPurchase(ids: [String]) {
		Task(priority: .background) {
			for id in ids {
				await storage.addToPurchased(id: id)
			}
		}
	}
	
	func addToCart(id: String) {
		Task(priority: .background) {
			await storage.addToCart(id: id)
			
			let cart = await storage.getCart()
			try await api.putOrder(payload: .init(nfts: cart.isEmpty ? nil : Array(cart)))
		}
	}
	
	func removeFromCart(id: String) {
		Task(priority: .background) {
			await storage.removeFromCart(id: id)
			
			let cart = await storage.getCart()
			try await api.putOrder(payload: .init(nfts: cart.isEmpty ? nil : Array(cart)))
		}
	}
	
	func isInCart(id: String) async -> Bool {
		return await storage.getCart().contains(id)
	}
}

// MARK: - favourite
extension NFTService {
	func addToFavourite(id: String) {
		Task(priority: .background) {
			await storage.addToFavourites(id: id)
			
			var likes = try await api.getProfile().likes
			likes.append(id)
			try await api.updateProfile(payload: .init(likes: likes))
		}
	}
	
	func removeFromFavourite(id: String) {
		Task(priority: .background) {
			await storage.removeFromFavourites(id: id)
			
			var likes = try await api.getProfile().likes
			likes.removeAll(where: { $0 == id })
			try await api.updateProfile(payload: .init(likes: likes))
		}
	}
	
	func isFavourite(id: String) async -> Bool {
		return await storage.getFavourites().contains(id)
	}
}
