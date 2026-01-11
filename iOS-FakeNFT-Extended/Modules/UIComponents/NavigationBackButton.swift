//
//  NavigationBackButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 28.12.2025.
//

import SwiftUI

extension View {
	func customNavigationBackButton(
		hasNotBackButton: Bool?,
		backAction: @escaping () -> Void
	) -> some View {
		self
			.navigationBarBackButtonHidden(true)
			.toolbar {
				if let hasNotBackButton {
					ToolbarItem(placement: .topBarLeading) {
						Button(action: backAction) {
							Image.chevronLeft
								.font(.chevronLeftIcon)
								.padding([.vertical, .trailing], 8)
						}
						.tint(.ypBlack)
						.opacity(hasNotBackButton ? 0 : 1)
						.disabled(hasNotBackButton)
					}
				}
			}
			.modifier(
				NavigationBackButton(hasNotBackButton: hasNotBackButton)
			)
	}
}

fileprivate struct NavigationBackButton: ViewModifier {
	@State private var prevHasNotBackButton = true
	private let hasNotBackButton: Bool
	
	init(hasNotBackButton: Bool?) {
		self.hasNotBackButton = hasNotBackButton ?? true
	}
	
	func body(content: Content) -> some View {
		content
			.task(priority: .userInitiated) {
				await updateGestureState()
			}
			.onChange(of: hasNotBackButton) {
				Task(priority: .userInitiated) {
					await updateGestureState()
				}
			}
	}
	
	private func updateGestureState() async {
		guard prevHasNotBackButton != hasNotBackButton else { return }
		prevHasNotBackButton = hasNotBackButton
		
		guard
			let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			let window = windowScene.windows.first,
			let navigationController = window.rootViewController?.navigationController ?? findNavigationController(in: window.rootViewController)
		else {
			print("failed to find navigation controller")
			return
		}
		
		navigationController.interactivePopGestureRecognizer?.isEnabled = !hasNotBackButton
		navigationController.interactivePopGestureRecognizer?.delegate = nil
		print("successfully updated gesture to isEnabled: \(!hasNotBackButton)")
	}
	
	private func findNavigationController(in viewController: UIViewController?) -> UINavigationController? {
		guard let viewController else { return nil }
		
		if let navigationController = viewController as? UINavigationController {
			return navigationController
		}
		
		for child in viewController.children {
			if let found = findNavigationController(in: child) {
				return found
			}
		}
		
		return nil
	}
}
