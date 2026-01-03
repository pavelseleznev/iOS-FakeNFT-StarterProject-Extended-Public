import SwiftUI

@main
struct iOS_FakeNFT_ExtendedApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	init() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
			if success {
				print("push notifiactions request granted")
			} else if let error {
				print("push notifications request failed: \(error.localizedDescription)")
			}
		}
		let _ = NetworkMonitor.shared
	}
    var body: some Scene {
        WindowGroup {
			CoordinatorView()
        }
    }
}
