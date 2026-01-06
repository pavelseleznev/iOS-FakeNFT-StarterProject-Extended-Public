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
    
    let originalProfile: ProfileModel
    
    private let profileService: ProfileServiceProtocol
    private let userPicturePlaceholder = "userPicturePlaceholder"

    
    // MARK: - Init
    init(
        profile: ProfileModel,
        profileService: ProfileServiceProtocol
    ) {
        self.profileService = profileService
        
        self.name = profile.name
        self.about = profile.about
        self.website = profile.website
        self.avatarURL = profile.avatarURL.isEmpty ? userPicturePlaceholder : profile.avatarURL
        self.originalProfile = profile
    }
    
    // MARK: - Computed flags
    var hasUnsavedChanges: Bool {
        name != originalProfile.name ||
        about != originalProfile.about ||
        website != originalProfile.website ||
        avatarURL != originalProfile.avatarURL
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
        
        let payload = ProfilePayload(
            name: name,
            description: about,
            avatar: avatarToSend,
            website: website,
            likes: nil
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
