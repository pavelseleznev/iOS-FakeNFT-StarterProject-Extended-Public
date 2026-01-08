//
//  NFTCollectionToolbarView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 30.12.2025.
//

import SwiftUI

fileprivate let filtrationItems = FilterToken.allCases.filter { !$0.isSortOption }
fileprivate let sortingItems = FilterToken.allCases.filter(\.isSortOption)

struct NFTCollectionToolbarView: View {
	@Binding var activeTokens: [FilterToken]
	let tokenAction: (FilterToken) -> Void
	let isActive: (FilterToken) -> Bool
	let atLeastOneSelected: Bool
	
	var body: some View {
		Menu {
			viewContainer {
				Menu {
					menuContent(for: filtrationItems)
				} label: {
					Text(.filtration)
					if !activeFiltrationTokens.isEmpty {
						Image.checkmarkCircle
							.transition(.scale)
					}
				}
			}
			
			viewContainer {
				Menu {
					menuContent(for: sortingItems)
				} label: {
					Text(.sorting)
					if !activeSortingTokens.isEmpty {
						Image.checkmarkCircle
							.transition(.scale)
					}
				}
			}
		} label: {
			Image(systemName: "line.3.horizontal.decrease.circle.fill")
				.foregroundStyle(atLeastOneSelected ? .cyan : .ypBlack)
		}
		.menuOrder(.fixed)
		.menuActionDismissBehavior(.disabled)
	}
	
	private func viewContainer<V: View>(_ content: () -> V) -> some View {
		Section {
			content()
				.menuActionDismissBehavior(.disabled)
		}
	}
	
	private func menuContent(for items: [FilterToken]) -> some View {
		ForEach(items) { token in
			buttonView(for: token)
		}
	}
	
	private func buttonView(for token: FilterToken) -> some View {
		Button {
			tokenAction(token)
		} label: {
			if isActive(token) { Image.checkmarkCircle }
			Text(token.title)
		}
	}
	
	private var activeFiltrationTokens: [FilterToken] {
		activeTokens.filter { !$0.isSortOption }
	}
	
	private var activeSortingTokens: [FilterToken] {
		activeTokens.filter(\.isSortOption)
	}
}
