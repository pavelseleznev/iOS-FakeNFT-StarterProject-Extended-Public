import Foundation

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
    case incorrectRequest(String)
}

protocol NetworkClient: Sendable {
    func send(request: NetworkRequest) async throws -> Data
	func send<T: Decodable & Sendable>(_ type: T.Type, request: NetworkRequest) async throws -> T
}

actor DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
    ) {
        self.session = session
        self.decoder = decoder
    }
}

// MARK: - DefaultNetworkClient Extensions

// --- internal methods ---
extension DefaultNetworkClient {
	func send(request: NetworkRequest) async throws -> Data {
		let urlRequest = try create(request: request)
		let (data, response) = try await session.data(for: urlRequest)
		guard let response = response as? HTTPURLResponse else {
			throw NetworkClientError.urlSessionError
		}
		guard 200 ..< 300 ~= response.statusCode else {
			throw NetworkClientError.httpStatusCode(response.statusCode)
		}
		return data
	}

	func send<T: Decodable & Sendable>(_ type: T.Type, request: NetworkRequest) async throws -> T {
		let data = try await send(request: request)
		return try await parse(data: data)
	}
}

// --- private helpers ---
private extension DefaultNetworkClient {
	private func create(request: NetworkRequest) throws -> URLRequest {
		guard let endpoint = request.endpoint else {
			throw NetworkClientError.incorrectRequest("Empty endpoint")
		}

		var urlRequest = URLRequest(url: endpoint)
		urlRequest.httpMethod = request.httpMethod.rawValue

		if let dto = request.dto {
			let params = dto.asFormURLEncodedParameters()
			let bodyString = formURLEncodedString(from: params)
			
			urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
			urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
			urlRequest.httpBody = bodyString.data(using: .utf8)
		}

		urlRequest.addValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
		return urlRequest
	}

	private func parse<T: Decodable>(data: Data) async throws -> T {
		do {
			return try decoder.decode(T.self, from: data)
		} catch {
			throw NetworkClientError.parsingError
		}
	}
	
	private func formURLEncodedString(from parameters: [String: String]) -> String {
		parameters.map { key, value in
			"\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
		}
		.joined(separator: "&")
	}
}

extension Encodable {
	func asFormURLEncodedParameters() -> [String: String] {
		let mirror = Mirror(reflecting: self)
		var params: [String: String] = [:]
		
		for child in mirror.children {
			guard let key = child.label else { continue }
			if let value = child.value as? String {
				params[key] = value
			} else if let value = child.value as? [String] {
				params[key] = value.joined(separator: ",")
			} else if let value = child.value as? [CustomStringConvertible] {
				params[key] = value.map { $0.description }.joined(separator: ",")
			} else if let value = child.value as? CustomStringConvertible {
				params[key] = value.description
			} else if let value = child.value as? OptionalProtocol, !value.isNil {
				params[key] = value.stringValue
			}
		}
		return params
	}
}

protocol OptionalProtocol {
	var isNil: Bool { get }
	var stringValue: String { get }
}

extension Optional: OptionalProtocol {
	var isNil: Bool { self == nil }
	var stringValue: String {
		switch self {
		case .some(let wrapped as CustomStringConvertible): return wrapped.description
		case .some(let wrapped as [CustomStringConvertible]): return wrapped.map { $0.description }.joined(separator: ",")
		case .some(let wrapped as String): return wrapped
		default: return ""
		}
	}
}
