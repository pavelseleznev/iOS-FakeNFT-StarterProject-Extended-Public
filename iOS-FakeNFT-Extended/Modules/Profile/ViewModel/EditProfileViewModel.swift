//
//  EditProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import Foundation

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
    var saveErrorMessage = "Не удалось сохранить данные"
    
	let originalProfile: ProfilePayload
    
    private let profileService: ProfileServiceProtocol
    private let userPicturePlaceholder = "userPicturePlaceholder"

    
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
    
    // MARK: - Computed flags
    var hasUnsavedChanges: Bool {
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
    
    // MARK: - Intents
    func changePhotoTapped() {
        isPhotoActionsPresented = false
        isPhotoURLAlertPresented = true
    }
    
    func deletePhotoTapped() {
        isPhotoActionsPresented = false
        photoURLInput = ""
        avatarURL = userPicturePlaceholder
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
        } catch {
            guard !error.isCancellation else { return }
            isSaveErrorPresented = true
            saveErrorMessage = "Не удалось сохранить данные"
            throw error
        }
    }
    
    func photoURLSaved(_ url: String) {
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
    
    func photoURLCancelled() {
        isPhotoURLAlertPresented = false
    }
}
