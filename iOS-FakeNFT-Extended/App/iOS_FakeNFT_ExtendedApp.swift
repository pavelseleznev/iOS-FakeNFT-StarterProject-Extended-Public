import SwiftUI
import BackgroundTasks

@main
struct iOS_FakeNFT_ExtendedApp: App {
	private static let backgroundUpdatesTaskIdentifier = "com.fakeNFT.backgroundUpdates"
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	@Environment(\.scenePhase) private var scenePhase
	
	@State private var updater: BackgroundUpdater
	private let appContainer: AppContainer
	private let localStorage = StorageActor.shared
	
	init() {
		appContainer = AppContainerBuilder.build()
		_updater = State(initialValue: .init(appContainer: appContainer))
		
		let _ = NetworkMonitor.shared // prerun
		
		requestNotificationPermission()
	}
	
    var body: some Scene {
        WindowGroup {
			CoordinatorView(
				appContainer: appContainer,
				didUpdatePath: updater.didUpdatePath,
				didUpdateTab: updater.didUpdateTab
			)
			.onReceive(
				NotificationCenter.default
					.publisher(for: .authStateChanged)
					.receive(on: RunLoop.main)
				,
				perform: handleAuthStateChangedNotification
			)
        }
		.backgroundTask(.appRefresh(Self.backgroundUpdatesTaskIdentifier)) {
			guard await isAuthed() else { return }
			await scheduleAppRefresh()
			await updater.performForceUpdate()
		}
		.onChange(of: scenePhase, performScenePhaseUpdateHandler)
    }
}

// MARK: - iOS_FakeNFT_ExtendedApp Extensions
// --- methods ---
private extension iOS_FakeNFT_ExtendedApp {
	func isAuthed() async -> Bool {
		await localStorage.value(forKey: Constants.isAuthedKey) ?? false
	}
	
	func handleAuthStateChangedNotification(_ notification: Notification) {
		let newAuthState = notification.userInfo?[Constants.isAuthedKey] as? Bool ?? false
		print("auth notification received with newAuthState: \(newAuthState)")
		
		guard newAuthState else {
			updater.stopLongPollingUpdates()
			return
		}
		scheduleAppRefresh()
		updater.startLongPollingUpdates()
	}
	
	func requestNotificationPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
			if success {
				print("push notifiactions request granted\n")
			} else if let error {
				print("push notifications request failed: \(error.localizedDescription)\n")
			}
		}
	}
	
	func performScenePhaseUpdateHandler(_: ScenePhase, newPhase: ScenePhase) {
		switch newPhase {
		case .active:
			updater.startLongPollingUpdates()
		case .inactive:
			updater.stopLongPollingUpdates()
		case .background:
			scheduleAppRefresh()
		@unknown default:
			break
		}
	}
	
	func scheduleAppRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: Self.backgroundUpdatesTaskIdentifier)
		
		request.earliestBeginDate = Date(timeIntervalSinceNow: Constants.bgTaskRefreshInterval)
		
		do {
			try BGTaskScheduler.shared.submit(request)
			print("BGTask scheduled: \(Self.backgroundUpdatesTaskIdentifier)")
		} catch {
			print("Failed to schedule BGTask: \(error.localizedDescription)")
		}
	}
}
