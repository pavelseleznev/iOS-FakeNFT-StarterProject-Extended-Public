import SwiftUI

@main
struct iOS_FakeNFT_ExtendedApp: App {
	init() { let _ = NetworkMonitor.shared }
    var body: some Scene {
        WindowGroup {
			CoordinatorView()
        }
    }
}
