import ATAIProfile
import Foundation

final class VDCProfileV3Analytics: ProfileV3AnalyticsReporting, @unchecked Sendable {
    func logEvent(_ name: String, asScreenView: Bool, parameters: [String: Any]) {
        AnalyticsEventManager.sharedInstance.logPostHogEvent(
            withName: name,
            asScreenView: asScreenView,
            parameters: parameters.mapValues { $0 as Any? }
        )
    }
}
