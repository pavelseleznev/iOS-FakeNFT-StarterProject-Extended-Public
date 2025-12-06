import Foundation

extension DateFormatter {
	@MainActor static let defaultDateFormatter = ISO8601DateFormatter()
}
