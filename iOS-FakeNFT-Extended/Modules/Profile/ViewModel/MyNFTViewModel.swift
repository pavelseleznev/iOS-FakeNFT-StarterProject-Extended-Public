//
//  MyNFTViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/19/25.
//

import Foundation

@MainActor
@Observable
final class MyNFTViewModel {
    
    var count: Int { items.count }
    private(set) var isLoading = false
    private(set) var items: [NFTModel] = []
    private(set) var sortOption: ProfileSortActionsViewModifier.SortOption = .name
    
    init(
        items: [NFTModel] = [],
        sortOption: ProfileSortActionsViewModifier.SortOption = .name) {
        self.sortOption = sortOption
        setItems(items)
    }
    
    func setItems(_ newItems: [NFTModel]) {
        items = newItems
        applySort()
    }
    
    func setLoading(_ value: Bool) {
        isLoading = value
    }
    
    func setSortOption(_ option: ProfileSortActionsViewModifier.SortOption) {
        sortOption = option
        applySort()
    }
    
    private func applySort() {
        switch sortOption {
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
