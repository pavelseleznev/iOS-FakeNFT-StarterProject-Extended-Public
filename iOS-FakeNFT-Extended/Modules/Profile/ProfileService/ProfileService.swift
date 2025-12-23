//
//  ProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/21/25.
//

import Foundation

@MainActor
protocol ProfileService {
    func fetchProfile() async throws -> ProfileModel
}
