//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Pavel Seleznev on 12/18/25.
//

import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    
    var loadErrorPresented = false
    var loadErrorMessage = "Не удалось загрузить данные"
    
    var myNFTTitle: String { "Мои NFT (\(myNFTCount))" }
    var favoriteTitle: String { "Избранные NFT (\(favoriteCount))" }
    
    private(set) var profile: ProfileModel = .init(
        name: "",
        about: "",
        website: "",
        avatarURL: ""
    )
    
    private(set) var myNFTCount: Int = 0
    private(set) var favoriteCount: Int = 0
    
    private var myNFTsTask: Task<Void, Never>?
    private var favoritesTask: Task<Void, Never>?
    private var hasLoaded = false
    private let appContainer: AppContainer
    private let push: (Page) -> Void
    private let myNFTStore: MyNFTViewModel
    private let favoriteNFTStore: FavoriteNFTViewModel
    
    init(
        appContainer: AppContainer,
        myNFTStore: MyNFTViewModel,
        favoriteNFTStore: FavoriteNFTViewModel,
        push: @escaping (Page) -> Void
    ) {
        self.appContainer = appContainer
        self.myNFTStore = myNFTStore
        self.favoriteNFTStore = favoriteNFTStore
        self.push = push
    }
    
    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        defer { hasLoaded = false }

        myNFTsTask?.cancel()
        favoritesTask?.cancel()
        do {
            let profileDTO = try await appContainer.api.getProfile()

            profile = ProfileModel(
                name: profileDTO.name,
                about: profileDTO.description,
                website: profileDTO.website,
                avatarURL: profileDTO.avatar
            )

            myNFTCount = profileDTO.nfts.count
            favoriteCount = profileDTO.likes.count

            myNFTsTask = Task(priority: .userInitiated) { [weak self] in
                await self?.loadMyNFTs(ids: profileDTO.nfts)
            }

            favoritesTask = Task(priority: .userInitiated) { [weak self] in
                await self?.loadFavoriteNFTs(ids: profileDTO.likes)
            }

        } catch is CancellationError {
            return
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            loadErrorPresented = true
            loadErrorMessage = "Не удалось загрузить данные"
        }
    }
    
    private func loadMyNFTs(ids: [String]) async {
        myNFTStore.setLoading(true)
        defer { myNFTStore.setLoading(false) }
        do {
            let dtos = try await fetchNFTs(ids: ids)
            myNFTStore.setItems(dtos.map(mapToNFTModel(isFavorite: false)))
        } catch is CancellationError {
            return
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            print("MyNFT load failed:", error)
        }
    }

    private func loadFavoriteNFTs(ids: [String]) async {
        favoriteNFTStore.setLoading(true)
        defer { favoriteNFTStore.setLoading(false) }
        do {
            let dtos = try await fetchNFTs(ids: ids)
            favoriteNFTStore.setItems(dtos.map(mapToNFTModel(isFavorite: true)))
        } catch is CancellationError {
            return
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            print("Favorite load failed:", error)
        }
    }
    
    func retryLoad() async {
        hasLoaded = false
        await load()
    }
    
    func websiteTapped() { push(.aboutAuthor(urlString: profile.website)) }
    
    func editTapped() { push(.editProfile(profile)) }
    
    func myNFTsTapped() { push(.myNFTs) }
    
    func favoriteNFTsTapped() { push(.favoriteNFTs) }
    
    private func mapToNFTModel(isFavorite: Bool) -> (NFTResponse) -> NFTModel {
        { dto in
            NFTModel(
                imageURLString: dto.imagesURLsStrings.first ?? "",
                name: dto.name,
                author: dto.authorSiteURL,
                cost: "\(dto.price) ETH",
                rate: "\(dto.ratingInt)/5",
                isFavorite: isFavorite,
                id: dto.id
            )
        }
    }
    
    private func fetchNFTs(ids: [String]) async throws -> [NFTResponse] {
        try await withThrowingTaskGroup(of: (Int, NFTResponse).self) { group in
            for (index, id) in ids.enumerated() {
                group.addTask { [api = appContainer.api] in
                    let dto = try await api.getNFT(by: id)
                    return (index, dto)
                }
            }

            var bucket: [(Int, NFTResponse)] = []
            bucket.reserveCapacity(ids.count)

            for try await pair in group { bucket.append(pair) }

            // preserve original ids order
            return bucket.sorted { $0.0 < $1.0 }.map(\.1)
        }
    }
    
    func applyUpdatedProfile(_ updated: ProfileModel) {
        profile = updated
    }
}
