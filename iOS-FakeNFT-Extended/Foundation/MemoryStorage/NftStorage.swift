import Foundation

protocol NFTStorageProtocol: Sendable, AnyObject {
	func addToPurchased(id: String) async
	func getPurchased() async -> Set<String>
	
	func addToCart(id: String) async
	func removeFromCart(id: String) async
	func getCart() async -> Set<String>
	func clearCart() async
	
	func getFavourites() async -> Set<String>
	func addToFavourites(id: String) async
	func removeFromFavourites(id: String) async
}

actor NFTStorage: NFTStorageProtocol {
	private var purchased = Set<String>()
	private var favourites = Set<String>()
	private var cart = Set<String>()
}

// MARK: - cart
extension NFTStorage {
	func addToCart(id: String) {
		cart.insert(id)
	}
	
	func removeFromCart(id: String) {
		cart.remove(id)
	}
	
	func getCart() -> Set<String> {
		cart
	}
	
	func clearCart() {
		cart = []
	}
}

// MARK: - favourite
extension NFTStorage {
	func getFavourites() -> Set<String> {
		favourites
	}

	func addToFavourites(id: String) {
		favourites.insert(id)
	}

	func removeFromFavourites(id: String) {
		favourites.remove(id)
	}
}

// MARK: - purchase
extension NFTStorage {
	func addToPurchased(id: String) {
		purchased.insert(id)
	}

	func getPurchased() -> Set<String> {
		purchased
	}
}
