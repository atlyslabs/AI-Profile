import Foundation

public protocol ProfileV3AnalyticsReporting: AnyObject, Sendable {
    func logEvent(_ name: String, asScreenView: Bool, parameters: [String: Any])
}
