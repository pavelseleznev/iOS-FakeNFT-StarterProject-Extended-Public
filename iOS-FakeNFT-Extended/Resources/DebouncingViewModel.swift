//
//  DebouncingViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 29.12.2025.
//

import Foundation
import Combine

@MainActor
final class DebouncingViewModel: ObservableObject {
	@Published var text: String = ""
	var onDebounce: ((String) -> Void)?
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		$text
			.removeDuplicates()
			.debounce(for: 0.3, scheduler: DispatchQueue.main)
			.sink { [weak self] newValue in
				self?.onDebounce?(newValue)
			}
			.store(in: &cancellables)
	}
}
