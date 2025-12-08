import Foundation

protocol NFTStorageProtocol: Sendable, AnyObject {
    func saveNft(_ nft: NFTResponse) async
    func getNft(with id: String) async -> NFTResponse?
}

// Пример простого актора, который сохраняет данные из сети
actor NFTStorage: NFTStorageProtocol {
    private var storage: [String: NFTResponse] = [:]

    func saveNft(_ nft: NFTResponse) async {
        storage[nft.id] = nft
    }

    func getNft(with id: String) async -> NFTResponse? {
        storage[id]
    }
}
