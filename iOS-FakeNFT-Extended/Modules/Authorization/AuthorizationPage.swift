//
//  AuthorizationPage.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 03.01.2026.
//

import Foundation

enum AuthorizationPage {
	case login, reg, restorePassword
	
	var title: String {
		switch self {
		case .login:
			String(localized: .authPageLoginTitle)
		case .reg:
			String(localized: .authPageRegTitle)
		case .restorePassword:
			String(localized: .authPageRestoreTitle)
		}
	}
	
	var mainButtonTitle: String {
		switch self {
		case .login:
			String(localized: .authPageLoginMainButtonTitle)
		case .reg:
			String(localized: .authPageRegMainButtonTitle)
		case .restorePassword:
			String(localized: .authPageRestoreMainButtonTitle)
		}
	}
	
	func description(state: AuthorizationState) -> (lgnV: String?, lgnD: String?, pswd: String?) {
		switch (self, state) {
		case (.login, .failure):
			(
				lgnV: String(localized: .authErrorInvalidEmail),
				lgnD: nil,
				pswd: String(localized: .authErrorLoginPSWD)
			)
		case (.login, .success):
			(
				lgnV: nil,
				lgnD: nil,
				pswd: String(localized: .authSuccessLoginPSWD)
			)
		case (.reg, .failure):
			(
				lgnV: String(localized: .authErrorInvalidEmail),
				lgnD: String(localized: .authErrorRegD),
				pswd: nil
			)
		case (.reg, .success):
			(
				lgnV: nil,
				lgnD: nil,
				pswd: String(localized: .authSuccessRegPSWD)
			)
		case (.restorePassword, .success):
			(
				lgnV: nil,
				lgnD: nil,
				pswd: String(localized: .authSuccessRestorePSWD)
			)
		case (.restorePassword, .failure):
			(
				lgnV: String(localized: .authErrorInvalidEmail),
				lgnD: String(localized: .authErrorRestoreD),
				pswd: nil
			)
		}
	}
	
	var error: LocalizedStringResource {
		switch self {
		case .login:
			.loginError
		case .reg:
			.regError
		case .restorePassword:
			.pswdResetError
		}
	}
}
