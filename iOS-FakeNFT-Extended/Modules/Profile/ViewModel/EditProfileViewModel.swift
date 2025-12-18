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
    
    let originalProfile: ProfileModel
    
    private let placeholderAvatar = "userPickPlaceholder"
    
    // MARK: - Init
    init(profile: ProfileModel) {
        self.name = profile.name
        self.about = profile.about
        self.website = profile.website
        self.avatarURL = profile.avatarURL.isEmpty ? placeholderAvatar : profile.avatarURL
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
        avatarURL = placeholderAvatar
    }
    
    func saveTapped(onSave: @escaping (ProfileModel) -> Void) {
        loadingState = .fetching
        
        Task { [weak self] in
            guard let self else { return }
            
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            let updated = ProfileModel(
                name: self.name,
                about: self.about,
                website: self.website,
                avatarURL: self.avatarURL
            )
            
            onSave(updated)
            self.loadingState = .idle
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
