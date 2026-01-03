//
//  AuthorizationView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//

import SwiftUI

fileprivate let appIconSize: CGFloat = 100

struct AuthorizationView: View {
	private let navigationTitle: String
	
	@State private var viewModel: AuthorizationViewModel
	@StateObject private var debouncer = DebouncingViewModel()
	
	@Environment(\.colorScheme) private var theme
	
	init(
		page: AuthorizationPage,
		secureStorage: AuthSecureStorage,
		onComplete: @escaping () -> Void,
		performLoginFlow: @escaping @MainActor () -> Void,
		performRegistrationFlow: @escaping @MainActor () -> Void,
		performForgotPasswordFlow: @escaping @MainActor () -> Void
	) {
		navigationTitle = page.title
		_viewModel = .init(
			initialValue: .init(
				page: page,
				secureStorage: secureStorage,
				onComplete: onComplete,
				performLoginFlow: performLoginFlow,
				performRegistrationFlow: performRegistrationFlow,
				performForgotPasswordFlow: performForgotPasswordFlow
			)
		)
	}
	
	var body: some View {
		ZStack {
			Color.ypWhite.ignoresSafeArea()
			
			Color.ypWhite.ignoresSafeArea()
				.padding(.horizontal)
				.padding(.horizontal)
				.gesture(keyboardDismissGesture)
			
			content
		}
		.overlay(content: blinkingAppIcon)
		.applyRepeatableAlert(
			isPresneted: $viewModel.errorIsPresented,
			message: viewModel.page.error,
			didTapRepeat: viewModel.performMainButtonAction
		)
		.animation(.default, value: viewModel.errorIsPresented)
		.navigationModifiers(title: navigationTitle)
		.keyboardMessageReceive(setFocusState: viewModel.setFocusState)
		.safeAreaInset(edge: .bottom, content: enterWithResetContent)
		.onAppear {
			viewModel.setFocusState(false)
			debouncer.onDebounce = viewModel.onDebounce
		}
		.onChange(of: viewModel.bindingPassword.wrappedValue) {
			viewModel.loginResult = nil
		}
		.applyToolbar()
	}
	
	private var content: some View {
		GeometryReader { geo in
			VStack(spacing: 16) {
				LoginTextField(
					text: $debouncer.text,
					placeholder: String(localized: .email),
					result: viewModel.page == .restorePassword ? $viewModel.loginResult : $viewModel.emailResult,
					messageAlignment: viewModel.emailMessageAlignemnt
				)
				
				if viewModel.page != .restorePassword {
					LoginTextField(
						text: viewModel.bindingPassword,
						placeholder: String(localized: .pswd),
						isSecure: true,
						result: $viewModel.loginResult,
						messageAlignment: .bottom
					)
				}
				Spacer()
			}
			.safeAreaPadding(.horizontal)
			.frame(width: geo.size.width, height: geo.size.height * 0.2)
			.position(
				x: geo.frame(in: .local).midX,
				y: geo.frame(in: .local).midY - (viewModel.isFocused ? 100 : 0)
			)
			.animation(.linear(duration: 0.15), value: viewModel.isFocused)
		}
		.ignoresSafeArea(.all)
	}
}

// MARK: - AuthorizationView Extensions
// --- subviews ---
fileprivate extension AuthorizationView {
	func blinkingAppIcon() -> some View {
		GeometryReader { geo in
			if !viewModel.isFocused {
				BlinkingAppIcon(imageSize: appIconSize)
					.position(
						x: geo.size.width / 2,
						y: geo.frame(in: .local).midY / 2
					)
					.transition(
						.asymmetric(
							insertion:
									.move(edge: .bottom)
									.combined(with: .scale),
							removal:
									.scale(scale: 0, anchor: .top)
									.combined(with: .offset(y: 80))
						)
					)
			}
		}
		.ignoresSafeArea(.all)
		.animation(
			Constants.defaultAnimation,
			value: viewModel.isFocused
		)
	}
	
	func enterWithResetContent() -> some View {
		VStack(spacing: 15) {
			
			authButton
			
			VStack(spacing: 8) {
				forgotPasswordView
				registrationButton
			}
			.font(.regular13)
			.foregroundStyle(.ypBlack)
		}
		.padding([.bottom, .horizontal])
	}
	
	private var authButton: some View {
		Button(action: viewModel.performMainButtonAction) {
			Group {
				Text(viewModel.page.mainButtonTitle)
					.font(.bold17)
					.opacity(viewModel.isLoading || viewModel.isSuccess ? 0 : 1)
					.overlay {
						Group {
							if viewModel.isSuccess {
								Image.checkmarkCircle
									.resizable()
									.scaledToFit()
									.foregroundStyle(.ypGreenUniversal)
									.transition(.scale)
							} else if viewModel.isLoading {
								ProgressView()
									.colorInvert()
									.progressViewStyle(.circular)
									.transition(.scale)
							}
						}
						.scaleEffect(1.2)
					}
			}
			.padding(.vertical, 8)
		}
		.nftButtonStyle(filled: true)
		.disabled(!viewModel.isFieldsValid || viewModel.isLoading)
		.animation(Constants.defaultAnimation, value: viewModel.isFieldsValid)
		.animation(Constants.defaultAnimation, value: viewModel.isLoading)
		.animation(Constants.defaultAnimation, value: viewModel.isSuccess)
	}
	
	@ViewBuilder
	private var forgotPasswordView: some View {
		if viewModel.page == .login && !viewModel.isFocused {
			Button(action: viewModel.performForgotPassword) {
				Text(.forgotPassword)
					.foregroundStyle(.accent)
			}
			.transition(.scale.combined(with: .opacity))
		}
	}
	
	@ViewBuilder
	private var registrationButton: some View {
		if viewModel.page == .login && !viewModel.isFocused {
			HStack {
				Text(.haventAnAccount)
				Button(action: viewModel.performRegistration) {
					Text(.register)
						.foregroundStyle(.accent)
				}
			}
			.transition(.scale.combined(with: .opacity))
		}
	}
}

// --- helpers ---
private extension AuthorizationView {
	var keyboardDismissGesture: some Gesture {
		DragGesture()
			.onChanged {
				if abs($0.translation.height) > 10 {
					viewModel.dismissKeyboard()
				}
			}
	}
}

// MARK: - View helpers
fileprivate extension View {
	func applyToolbar() -> some View {
		self
			.toolbar {
				ToolbarItem(placement: .title) {
					Image(.vector)
						.resizable()
						.scaledToFit()
						.scaleEffect(0.6)
				}
			}
	}
	
	func navigationModifiers(title: String) -> some View {
		self
			.navigationTitle(title)
			.navigationBarTitleDisplayMode(.large)
	}
	
	func keyboardMessageReceive(setFocusState: @escaping (Bool) -> Void) -> some View {
		self
			.onReceive(
				NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
			) { _ in
				setFocusState(false)
			}
			.onReceive(
				NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
			) { _ in
				withAnimation(Constants.defaultAnimation) {
					setFocusState(true)
				}
			}
	}
}

// MARK: - Preview
#if DEBUG
#Preview {
	NavigationStack {
		AuthorizationView(
			page: .login,
			secureStorage: .init(service: Constants.userDataKeychainService),
			onComplete: {},
			performLoginFlow: {},
			performRegistrationFlow: {},
			performForgotPasswordFlow: {}
		)
	}
}
#endif
