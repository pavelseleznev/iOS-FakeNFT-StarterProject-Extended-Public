//
//  Error.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 1/4/26.
//

import Foundation

extension Error {
    var isCancellation: Bool {
        self is CancellationError || (self as? URLError)?.code == .cancelled
    }
}
