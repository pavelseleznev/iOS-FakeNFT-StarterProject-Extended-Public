//
//  EditProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import SwiftUI

@MainActor
@Observable
final class EditProfileViewModel {
    
    // MARK: - Properties
    var name: String
    var about: String
    var website: String
    var avatarURL: String
    
    var showExitAlert = false
    var isPhotoActionsPresented = false
    var isPhotoURLAlertPresented = false
    var photoURLInput = ""
    var loadingState: LoadingState = .idle
    var isSaveErrorPresented = false
    var saveErrorMessage: LocalizedStringResource = .editProfileSaveError
    var editProfileTitle: LocalizedStringResource = .editProfileTitle
    
	private(set) var keyboardHeight: CGFloat = 0
	private var originalProfile: ProfilePayload
    
	@ObservationIgnored private let profileService: ProfileServiceProtocol
	@ObservationIgnored private let userPicturePlaceholder = "userPicturePlaceholder"

    
    // MARK: - Init
    init(
		profile: ProfilePayload,
        profileService: ProfileServiceProtocol
    ) {
        self.profileService = profileService
        
        self.name = profile.name ?? "no name"
		self.about = profile.description ?? "no about"
		self.website = profile.website ?? "no url"
		
		let avatar = profile.avatar ?? ""
		self.avatarURL = avatar.isEmpty ? userPicturePlaceholder : avatar
        self.originalProfile = profile
    }
}

// MARK: - EditProfileViewModel Extensions
// --- helpers ---
extension EditProfileViewModel {
	func changePhotoTapped() {
		isPhotoActionsPresented = false
		isPhotoURLAlertPresented = true
	}
	
	func deletePhotoTapped() {
		isPhotoActionsPresented = false
		photoURLInput = ""
		avatarURL = userPicturePlaceholder
	}
	
	func keyboardWillChangeFrame(_ notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
			
		if let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			let keyboardFrame = keyboardFrameValue.cgRectValue
			keyboardHeight = keyboardFrame.height - keyboardFrame.height * 0.2
		}
	}
}

// --- saves ---
extension EditProfileViewModel {
	private var hasUnsavedChanges: Bool {
		name != originalProfile.name ?? "" ||
		about != originalProfile.description ?? "" ||
		website != originalProfile.website ?? "" ||
		avatarURL != originalProfile.avatar ?? ""
	}
	
	var canSave: Bool {
		let trim: (String) -> String = { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
		return !trim(name).isEmpty &&
		!trim(about).isEmpty &&
		!trim(website).isEmpty &&
		hasUnsavedChanges
	}
	
	func saveTapped() async throws {
		let avatarToSend = (avatarURL == userPicturePlaceholder) ? "" : avatarURL
		
		let payload = ProfileContainerModel(
			name: name,
			avatarURLString: avatarToSend,
			websiteURLString: website,
			description: about
		)
		
		loadingState = .fetching
		
		do {
			defer { loadingState = .idle }
			try await profileService.update(with: payload)
			
			originalProfile = .init(
				name: name,
				description: about,
				avatar: avatarURL,
				website: website
			)
		} catch {
			guard !error.isCancellation else { return }
			isSaveErrorPresented = true
			saveErrorMessage = "Не удалось сохранить данные"
			throw error
		}
	}
	
	func savePhotoURLString(_ url: String) {
		let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
		
		isPhotoURLAlertPresented = false
		isPhotoActionsPresented = false
		
		guard !trimmed.isEmpty else {
			photoURLInput = ""
			return
		}
		
		photoURLInput = trimmed
		avatarURL = trimmed
	}
	
	func performSave() async {
		do {
			try await saveTapped()
		} catch {
			guard !(error is CancellationError) else { return }
			print("Save profile failed:", error)
			isSaveErrorPresented = true
		}
	}
}
