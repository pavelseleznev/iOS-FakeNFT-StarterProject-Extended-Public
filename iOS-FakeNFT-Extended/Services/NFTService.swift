import Foundation

protocol NFTServiceProtocol: Sendable {
    func didLoadUserData(
        likes: [String],
        purchased: [String],
        cart: [String]
    ) async
    
    func loadNFT(id: String) async throws -> NFTResponse
    
    func didPurchase(id: String) async
    
    func addToCart(id: String) async
    func removeFromCart(id: String) async
    func isInCart(id: String) async -> Bool
    
    func isFavourite(id: String) async -> Bool
    func removeFromFavourite(id: String) async
    func addToFavourite(id: String) async
}

actor NFTService: NFTServiceProtocol {
    private let api: ObservedNetworkClient
    private let storage: NFTStorageProtocol

    init(api: ObservedNetworkClient, storage: NFTStorageProtocol) {
        self.storage = storage
        self.api = api
    }
}

// --- helpers ---
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

// --- cart ---
extension NFTService {
    func didPurchase(id: String) {
        Task {
            await storage.addToPurchased(id: id)
        }
    }
    
    func addToCart(id: String) {
        Task {
            await storage.addToCart(id: id)
            
            let cart = await storage.getCart()
            try await api.putOrderAndPay(payload: .init(nfts: cart.isEmpty ? nil : Array(cart)))
        }
    }
    
    func removeFromCart(id: String) {
        Task {
            await storage.removeFromCart(id: id)
            
            let cart = await storage.getCart()
            try await api.putOrderAndPay(payload: .init(nfts: cart.isEmpty ? nil : Array(cart)))
        }
    }
    
    func isInCart(id: String) async -> Bool {
        return await storage.getCart().contains(id)
    }
}

// --- favourite ---
extension NFTService {
    func addToFavourite(id: String) {
        Task {
            await storage.addToFavourites(id: id)
            
            var likes = try await api.getProfile().likes
            likes.append(id)
            try await api.updateProfile(payload: .init(likes: likes))
        }
    }
    
    func removeFromFavourite(id: String) {
        Task {
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
