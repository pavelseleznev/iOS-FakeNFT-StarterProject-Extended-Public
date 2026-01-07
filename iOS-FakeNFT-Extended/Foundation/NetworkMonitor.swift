//
//  NetworkMonitor.swift
//  iOS-FakeNFT-Extended
//
//  Created by Superior Warden on 02.01.2026.
//

import Network
import Combine

@MainActor
final class NetworkMonitor: ObservableObject {
	static let shared = NetworkMonitor()
	
	@Published private var isReachable = false
	@Published private var interfaceType: InterfaceType = .unknown
	@Published private var isExpensive = false
	
	enum InterfaceType {
		case wifi, cellular, wired, other, unknown
	}
	
	private let monitor = NWPathMonitor()
	private let queue = DispatchQueue(label: "NetworkMonitor.queue")
	
	private init() {
		startMonitoring()
	}
	
	deinit {
		monitor.cancel()
	}
	
	private func startMonitoring() {
		monitor.pathUpdateHandler = { [weak self] path in
			guard let self else { return }
			
			Task(priority: .utility) { @MainActor in
				self.isReachable = path.status == .satisfied
				self.isExpensive = path.isExpensive
				self.interfaceType = self.classifyInterface(path)
				
				// Debug log
				print("Network: \(self.isReachable ? "Online" : "Offline") | \(self.interfaceType) | Expensive: \(self.isExpensive)")
			}
		}
		monitor.start(queue: queue)
	}
	
	private func classifyInterface(_ path: NWPath) -> InterfaceType {
		if path.usesInterfaceType(.wifi) { return .wifi }
		if path.usesInterfaceType(.cellular) { return .cellular }
		if path.usesInterfaceType(.wiredEthernet) { return .wired }
		if path.availableInterfaces.isEmpty { return .unknown }
		return .other
	}
	
	/// Синхронная проверка (cached)
	var isOnline: Bool { isReachable }
	
	/// Только WiFi (без cellular)
	var isWifiOnly: Bool { interfaceType == .wifi }
	
	/// Low quality (cellular + expensive)
	var isLowQuality: Bool { interfaceType == .cellular || isExpensive }
}
