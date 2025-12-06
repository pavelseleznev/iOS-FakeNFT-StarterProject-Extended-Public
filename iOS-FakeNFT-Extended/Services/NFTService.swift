import Foundation

protocol NFTServiceProtocol: Sendable {
    func loadNft(id: String) async throws -> NFT
}

actor NFTService: NFTServiceProtocol {

	private let api: ObservedNetworkClient
	private let storage: NFTStorageProtocol

	init(api: ObservedNetworkClient, storage: NFTStorageProtocol) {
        self.storage = storage
        self.api = api
    }

    func loadNft(id: String) async throws -> NFT {
        if let nft = await storage.getNft(with: id) {
            return nft
        }

		let nft = try await api.getNFT(by: id)
        await storage.saveNft(nft)
        return nft
    }
}
