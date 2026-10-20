#if DEBUG
import Foundation

enum ProfileV3DebugKYCScenario: String, CaseIterable, Identifiable, Sendable {
    case live
    case noPassport
    case noKYC
    case reKYC

    static let didChange = Notification.Name("profileV3.debug.kycScenarioDidChange")
    private static let defaultsKey = "profileV3.debug.kycScenario"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .live: return "Live"
        case .noPassport: return "No passport"
        case .noKYC: return "No KYC"
        case .reKYC: return "Re-KYC"
        }
    }

    var detail: String {
        switch self {
        case .live: return "Board as the server sends it"
        case .noPassport: return "Selfie and Gmail done, passport missing"
        case .noKYC: return "Nothing captured yet"
        case .reKYC: return "KYC expired, capture again"
        }
    }

    static var current: ProfileV3DebugKYCScenario {
        get { UserDefaults.standard.string(forKey: defaultsKey).flatMap(Self.init(rawValue:)) ?? .live }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: defaultsKey)
            NotificationCenter.default.post(name: didChange, object: nil)
        }
    }
}

extension ProfileV3Board {
    func applying(_ scenario: ProfileV3DebugKYCScenario) -> ProfileV3Board {
        guard scenario != .live, let main = mainProfile else { return self }
        let pass = main.pass.applying(scenario, profileID: main.profileID)
        let profiles = profiles.map { profile in
            var home = profile.home
            home.worldPasses = home.worldPasses.map { $0.id == pass.id ? pass : $0 }
            if profile.profileID == main.profileID {
                home = home.applying(scenario, pass: pass)
            }
            return ProfileV3ProfileBoard(
                profileID: profile.profileID,
                isMain: profile.isMain,
                name: profile.name,
                pass: profile.profileID == main.profileID ? pass : profile.pass,
                home: home
            )
        }
        return ProfileV3Board(profiles: profiles, settings: settings)
    }
}

private extension ProfileV3WorldPass {
    func applying(_ scenario: ProfileV3DebugKYCScenario, profileID: String) -> ProfileV3WorldPass {
        var pass = self
        switch scenario {
        case .live:
            return self
        case .noPassport:
            pass.kycStatus = .notStarted
            pass.kycGlowTone = .hidden
            pass.kycLine = nil
            pass.kycProgress = ProfileV3KYCProgress(done: 2, total: 3)
            pass.kycCapture = ProfileV3KYCCapture(
                profileID: profileID,
                route: .session,
                steps: [ProfileV3CaptureStepKey.passport]
            )
        case .noKYC:
            pass.kycStatus = .notStarted
            pass.kycGlowTone = .hidden
            pass.kycLine = nil
            pass.kycProgress = nil
            pass.kycCapture = ProfileV3KYCCapture(
                profileID: profileID,
                route: .session,
                steps: [
                    ProfileV3CaptureStepKey.passport,
                    ProfileV3CaptureStepKey.selfie,
                    ProfileV3CaptureStepKey.gmailConnect
                ]
            )
        case .reKYC:
            pass.kycStatus = .expired(on: "")
            pass.kycGlowTone = .negative
            pass.kycLine = ProfileV3KYCLine(title: "KYC expired", subtitle: "Capture your passport again")
            pass.kycProgress = nil
            pass.kycCapture = ProfileV3KYCCapture(
                profileID: profileID,
                route: .session,
                steps: [ProfileV3CaptureStepKey.passport, ProfileV3CaptureStepKey.selfie]
            )
        }
        return pass
    }
}

private extension ProfileV3Home {
    func applying(_ scenario: ProfileV3DebugKYCScenario, pass: ProfileV3WorldPass) -> ProfileV3Home {
        var home = self
        home.kycStatus = pass.kycStatus
        home.kycProgress = pass.kycProgress
        home.kycLine = pass.kycLine
        home.needsKYCReconnect = false
        home.kycBannerTitle = nil
        switch scenario {
        case .live:
            return self
        case .noPassport:
            home.kycStatusLabel = "Passport missing"
            home.kycActionLabel = "Add passport"
        case .noKYC:
            home.kycStatusLabel = "KYC incomplete"
            home.kycActionLabel = "Complete KYC"
        case .reKYC:
            home.kycStatusLabel = "KYC expired"
            home.kycActionLabel = "Redo KYC"
        }
        return home
    }
}
#endif
