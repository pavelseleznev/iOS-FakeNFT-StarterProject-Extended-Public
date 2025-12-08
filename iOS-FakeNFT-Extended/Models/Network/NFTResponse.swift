import Foundation

struct NFTResponse: Decodable {
	let createdAt: String
	let name: String
	let imagesURLsStrings: [String]
	let ratingInt: Int
	let description: String
	let price: Float
	let authorSiteURL: String
	let id: String
	
	enum CodingKeys: String, CodingKey {
		case createdAt, name, description, id, price
		case imagesURLsStrings = "images"
		case ratingInt = "rating"
		case authorSiteURL = "author"
	}
}
