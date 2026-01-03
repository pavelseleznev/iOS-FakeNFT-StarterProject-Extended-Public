//
//  AuthorizationViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//

import SwiftUI

@MainActor
@Observable
final class AuthorizationViewModel {
	let page: AuthorizationPage
	private let secureStorage: AuthSecureStorage
	private let onComplete: () -> Void
	private let performLoginFlow: @MainActor () -> Void
	private let performRegistrationFlow: @MainActor () -> Void
	private let performForgotPasswordFlow: @MainActor () -> Void
	
	private let notificationTrigger = UNTimeIntervalNotificationTrigger(
		timeInterval: 0.1,
		repeats: false
	)
	
	private(set) var isSuccess = false
	private(set) var isFocused = false
	private(set) var isLoading = false
	
	var errorIsPresented = false
	var emailResult: LoginResult?
	var loginResult: LoginResult?
	
	private var pendingPassword: String?
	private var email = ""
	private var password = ""
	
	@ObservationIgnored
	private var existingEmails = Set<String>()
	
	var bindingPassword: Binding<String> {
		.init(
			get: { [weak self] in self?.password ?? "DEINITED" },
			set: { [weak self] in
				print("Password changed to \($0)")
				self?.password = $0
			}
		)
	}
	
	init(
		page: AuthorizationPage,
		secureStorage: AuthSecureStorage,
		onComplete: @escaping () -> Void,
		performLoginFlow: @escaping @MainActor () -> Void,
		performRegistrationFlow: @escaping @MainActor () -> Void,
		performForgotPasswordFlow: @escaping @MainActor () -> Void
	) {
		self.page = page
		self.secureStorage = secureStorage
		self.onComplete = onComplete
		self.performLoginFlow = performLoginFlow
		self.performRegistrationFlow = performRegistrationFlow
		self.performForgotPasswordFlow = performForgotPasswordFlow
		
		Task(priority: .userInitiated) { @MainActor in
			do {
				existingEmails = Set(try await secureStorage.getAllAccounts().map(\.username))
			} catch {
				print("cant get existing emails: \(error.localizedDescription)")
			}
		}
	}
}

// MARK: - AuthorizationViewModel Extensions
// --- internal helpers ---
extension AuthorizationViewModel {
	func setFocusState(_ state: Bool) {
		isFocused = state
	}
	
	var isFieldsValid: Bool {
		switch page {
		case .login, .reg:
			validateEmail() == nil && !email.isEmpty && !password.isEmpty && password.count >= 5
		case .restorePassword:
			validateEmail() == nil && !email.isEmpty
		}
	}
	
	func onDebounce(_ email: String) {
		self.email = email
		
		let _result = validateEmail()
		let result: LoginResult? = _result == nil ? nil : .failure(_result)
		
		if case .restorePassword = page {
			loginResult = result
		} else {
			emailResult = result
		}
	}
	
	func validateEmail() -> String? {
		guard !email.isEmpty else { return nil }
		
		// email regex check
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		if email.range(of: emailRegex, options: .regularExpression) == nil {
			return page.description(state: .failure).lgnV
		}
		
		// reg duplicate check
		if case .reg = page {
			if existingEmails.contains(email) {
				return page.description(state: .failure).lgnD
			}
		}
		
		// restore no user check
		if case .restorePassword = page {
			if !existingEmails.contains(email) {
				return page.description(state: .failure).lgnD
			}
		}
		
		return nil
	}
	
	var emailMessageAlignemnt: Edge {
		switch [.login, .reg].contains(page) ? emailResult : loginResult {
			case .failure:
				return .top
			case .success:
				return .bottom
			case nil:
				return .top
			}
	}
}

// --- private helpers ---
private extension AuthorizationViewModel {
	func generatePassword(length: Int = 12) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
		let numbers = "0123456789"
		let specials = "!@#$%^&*()_+-=[]{}|;:,.<>?"
		
		let allChars = letters + numbers + specials
		return String((0..<length).map { _ in allChars.randomElement()! })
	}
	
	func getPushNotificationContent() -> UNMutableNotificationContent {
		let content = UNMutableNotificationContent()
		content.title = String(localized: .loginPushNotificationTitle)
		content.body = String(localized:.loginPushNotificationBody(
			password: password,
			username: email
		))
		content.sound = .default
		content.userInfo = ["notificationEvent" : "notification"]
		
		return content
	}
	
	func sendPushNotificationWithNewPassword(_ password: String) async {
		let content = getPushNotificationContent()
		

		let request = UNNotificationRequest(
			identifier: UUID().uuidString,
			content: content,
			trigger: notificationTrigger
		)
		
		do {
			try await UNUserNotificationCenter.current().add(request)
			print("push with new password was sent")
		} catch {
			print(error.localizedDescription)
		}
	}
	
	func simulateFetching() async throws {
		try await Task.sleep(for: .seconds(2))
	}
	
	func onSuccededAction() async throws {
		try await simulateFetching()
		onComplete()
	}
	
	func onError(_ description: String) {
		print(description)
		errorIsPresented = true
	}
	
	func changePassword(to pswd: String) async -> Bool {
		do {
			try await secureStorage.changePassword(username: email, newPassword: pswd)
			pendingPassword = nil
			isSuccess = true
			try await simulateFetching()
			performLoginFlow()
			
			return true
		} catch {
			onError("counldn't change password for email: \(email) | error: \(error.localizedDescription)")
			
			return false
		}
	}
}

// --- actions handlers ---
private extension AuthorizationViewModel {
	func handleRegAction() async {
		do {
			try await secureStorage.register(username: email, password: password)
			isSuccess = true
			loginResult = .success(page.description(state: .success).pswd)
			emailResult = .success("")
			
			performLoginFlow()
		} catch {
			onError(
				"couldn't register user with email: \(email) " +
				", password: \(password) | error: \(error.localizedDescription)"
			)
		}
	}
	
	func handleLoginAction() async {
		do {
			let expectedPassword = try await secureStorage.login(username: email)
			guard expectedPassword == password else {
				loginResult = .failure(page.description(state: .failure).pswd)
				emailResult = .failure("")
				return
			}
			
			isSuccess = true
			loginResult = .success(page.description(state: .success).pswd)
			emailResult = .success("")
			
			try await onSuccededAction()
		} catch {
			onError(
				"couldn't get password for email: \(email) | error: \(error.localizedDescription)"
			)
		}
	}
	
	func handleRestorePasswordAction() async {
		let newPassword: String
		
		if let pendingPassword {
			newPassword = pendingPassword
		} else {
			newPassword = generatePassword()
			pendingPassword = newPassword
		}
		
		guard await changePassword(to: newPassword) else {
			loginResult = .failure("")
			return
		}
		
		loginResult = .success(page.description(state: .success).pswd)
		
		await sendPushNotificationWithNewPassword(newPassword)
		
		UIPasteboard.general.string = newPassword
	}
}

// --- navigation ---
extension AuthorizationViewModel {
	func performMainButtonAction() {
		dismissKeyboard()
		guard !isLoading else { return }
		isLoading = true
		
		Task(priority: .high) {
			defer { isLoading = false }
			
			try? await self.simulateFetching()
			switch page {
			case .reg:
				await handleRegAction()
			case .login:
				await handleLoginAction()
			case .restorePassword:
				await handleRestorePasswordAction()
			}
		}
	}
	
	func performForgotPassword() {
		performForgotPasswordFlow()
	}
	
	func performRegistration() {
		performRegistrationFlow()
	}
	
	func dismissKeyboard() {
		UIApplication.shared
			.sendAction(
				#selector(UIResponder.resignFirstResponder),
				to: nil,
				from: nil,
				for: nil
			)
	}
}
