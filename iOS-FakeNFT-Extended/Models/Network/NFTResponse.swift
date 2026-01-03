import Foundation

struct NFTResponse: Decodable, Identifiable {
    let createdAt: String
    let name: String
    let imagesURLsStrings: [String]
    let rating: Int
    let description: String
    let price: Float
    let authorName: String
    let website: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt, name, description, id, price, rating, website
        case imagesURLsStrings = "images"
        case authorName = "author"
    }
    
    static var mock: Self {
        .init(
            createdAt: Date.now.formatted(.iso8601),
            name: "Treasures of Westeros",
            imagesURLsStrings: ["https://public.bnbstatic.com/static/content/square/images/21ba7a4483794ab5a1bfb2cf9a3338ab.png"],
            rating: 2,
            description: "Bla Bla Bla",
            price: 14.78,
            authorName: "Daenerys Targaryen",
            website: "https://google.com",
            id: UUID().uuidString
        )
    }
    
    static var badImageURLMock: Self {
        .init(
            createdAt: Date.now.formatted(.iso8601),
            name: "Name",
            imagesURLsStrings: [],
            rating: 4,
            description: "Bla Bla Bla",
            price: 99.99,
            authorName: "John Snow",
            website: "https://google.com",
            id: UUID().uuidString
        )
    }
}
