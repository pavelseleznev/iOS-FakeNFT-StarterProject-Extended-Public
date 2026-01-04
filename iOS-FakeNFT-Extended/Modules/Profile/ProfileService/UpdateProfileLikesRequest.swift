//
//  UpdateProfileLikesRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/29/25.
//


import Foundation

struct UpdateProfileLikesRequest: NetworkRequest {
    private let likeIDs: [String]

    init(likeIDs: [String]) {
        self.likeIDs = likeIDs
    }
    
    var dto: Encodable? {
        let likesToSend = likeIDs.isEmpty ? ["null"] : likeIDs
        return UpdateLikesDTO(likes: likesToSend)
    }

    var endpoint: URL? { URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1") }
    var httpMethod: HttpMethod { .PUT }
}
