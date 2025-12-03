import Foundation

protocol NFTStorageProtocol: Sendable, AnyObject {
    func saveNft(_ nft: NFT) async
    func getNft(with id: String) async -> NFT?
}

// Пример простого актора, который сохраняет данные из сети
actor NFTStorage: NFTStorageProtocol {
    private var storage: [String: NFT] = [:]

    func saveNft(_ nft: NFT) async {
        storage[nft.id] = nft
    }

    func getNft(with id: String) async -> NFT? {
        storage[id]
    }
}
