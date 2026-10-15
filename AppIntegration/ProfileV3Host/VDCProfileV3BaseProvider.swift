import ATAIProfile
import Foundation
import UIKit

final class VDCProfileV3BaseProvider: ProfileV3ConfigurationProviding, @unchecked Sendable {
    private let tokenProvider: FirebaseAuthTokenProvider?

    @MainActor
    init() {
        tokenProvider = (UIApplication.shared.delegate as? AppDelegate)?.authTokenProvider
    }

    var baseURL: URL {
        let baseURLString = APIConstants.BaseURL.getBaseURL()
        guard let url = URL(string: baseURLString) else {
            preconditionFailure("Invalid API base URL string: \(baseURLString)")
        }
        return url
    }

    var userToken: String? {
        tokenProvider?.getAuthToken()
    }

    var userResidencyCode: String {
        HomeIdentityProvider.residenceCode
    }

    var currentUserID: String? {
        UserData.currentUser?.userUid
    }

    @MainActor var isGuestSession: Bool {
        GuestSession.firebaseResolver()
    }

    func sendEvent(event: String, isScreenView: Bool?, screenName: String?, params: [String: Any]) {
        AnalyticsEventManager.sharedInstance.logPostHogEvent(
            withName: screenName ?? event,
            asScreenView: isScreenView == true,
            parameters: params.mapValues { $0 as Any? }
        )
    }
}
