//
//  NFTsIDsStorageProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 04.01.2026.
//

import Foundation


protocol NFTsIDsStorageProtocol: Sendable, AnyObject {
	func get() async -> Set<String>
	func replaceIDs<S: Sequence & Sendable>(withLoaded ids: S) async where S.Element == String
	func add(_ id: String) async
	func remove(_ id: String) async
	func clear() async
}

actor NFTsIDsStorage: NFTsIDsStorageProtocol {
	private var saveTask: Task<Void, Never>?
	
	private var ids = Set<String>()
	private let kind: NFTsIDsKind
	private let storage = StorageActor.shared
	
	init(kind: NFTsIDsKind) {
		self.kind = kind
		
		Task(priority: .userInitiated) {
			await self.restoreFromStorage()
		}
	}
	
	private func restoreFromStorage() async {
		if let value: [String] = await storage.value(forKey: kind.userDefaultsKey) {
			ids = Set(value)
			print("\nids restored for \(kind.userDefaultsKey) from storage")
		}
	}
	
	private func scheduleSave() {
		saveTask?.cancel()
		saveTask = Task(priority: .background) { @MainActor in
			do {
				try await Task.sleep(for: .seconds(0.5))
				
				guard !Task.isCancelled else { return }
				await storage.set(Array(ids), forKey: kind.userDefaultsKey)
				print("\nids saved for \(kind.userDefaultsKey) in storage")
			} catch is CancellationError {
				print("\(#file) | \(#function) cancelled")
			} catch {
				print("\(#file) | \(#function) failed to save ids: \(error.localizedDescription)")
			}
		}
	}
	
	private func sendUpdates() {
		Task(priority: .background) { @MainActor in
			let _ids = await Array(ids)
			
			NotificationCenter.default.post(
				name: kind.notificationName,
				object: nil,
				userInfo: ["ids" : _ids]
			)
			
			print("\nupdate notificaiton send for \(kind)")
		}
	}
}

// MARK: - NFTsIDsStorage Extensions
// --- methods ---
extension NFTsIDsStorage {
	func get() -> Set<String> {
		ids
	}
	
	func replaceIDs<S: Sequence & Sendable>(withLoaded ids: S) async where S.Element == String {
		self.ids = Set(ids)
		sendUpdates()
		scheduleSave()
	}
	
	func add(_ id: String) {
		ids.insert(id)
		sendUpdates()
		scheduleSave()
	}
	
	func remove(_ id: String) {
		ids.remove(id)
		sendUpdates()
		scheduleSave()
	}
	
	func clear() {
		ids = []
		sendUpdates()
		scheduleSave()
	}
}
