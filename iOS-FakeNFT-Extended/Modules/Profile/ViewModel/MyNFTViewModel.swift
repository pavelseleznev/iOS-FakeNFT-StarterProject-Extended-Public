//
//  MyNFTViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/19/25.
//

import Foundation

final class MyNFTViewModel: ObservableObject {
    @Published private(set) var items: [NFTModel]
    
    init(items: [NFTModel]) {
        self.items = items
        sort(by: .name)
    }
    
    func sort(by option: ProfileSortActionsViewModifier.SortOption) {
        switch option {
        case .name:
            items.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .cost:
            items.sort { value(from: $0.cost) < value(from: $1.cost) }
        case .rate:
            items.sort { ratingValue(from: $0.rate) > ratingValue(from: $1.rate) }
        }
    }
    
    private func value(from costString: String) -> Double {
        let numberPart = costString
            .components(separatedBy: CharacterSet(charactersIn: "0123456789,." ).inverted)
            .joined()
            .replacingOccurrences(of: ",", with: ".")
        return Double(numberPart) ?? 0
    }
    
    private func ratingValue(from rateString: String) -> Double {
        let left = rateString.split(separator: "/").first ?? ""
        return Double(left.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
}
