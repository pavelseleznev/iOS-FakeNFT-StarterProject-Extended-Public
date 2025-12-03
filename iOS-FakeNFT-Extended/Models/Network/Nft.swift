import Foundation

struct NFT: Decodable, Hashable {
    let id: String
    let images: [URL]
}
