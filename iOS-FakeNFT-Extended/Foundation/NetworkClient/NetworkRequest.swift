import Foundation

enum HttpMethod: String {
    case GET, PUT, POST
}

protocol NetworkRequest: Sendable {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Encodable? { get }
}

// default values
extension NetworkRequest {
    var httpMethod: HttpMethod { .GET }
    var dto: Encodable? { nil }
}
