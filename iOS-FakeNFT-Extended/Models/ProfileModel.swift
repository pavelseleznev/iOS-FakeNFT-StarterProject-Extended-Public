//
//  ProfileModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/15/25.
//

import Foundation

struct ProfileModel {
    let name: String
    let about: String
    let website: String
    let avatarURL: String
}

extension ProfileModel {
    static var preview: ProfileModel { MockProfileProvider().profile() }
}
