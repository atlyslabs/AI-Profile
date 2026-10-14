import Foundation

struct ProfileV3Passport: Identifiable, Equatable {
    enum Status: Equatable {
        case active
        case expired
    }

    let id: String
    var holderName: String
    var number: String
    var countryName: String
    var countryNativeName: String?
    var issuedOn: String
    var expiresOn: String
    var status: Status = .active
}

enum ProfileV3PassportChangeReason: String, CaseIterable, Identifiable {
    case lost
    case pagesOver = "pages_over"
    case validityExpired = "validity_expired"
    case damaged

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lost: return ProfileV3Strings.passportReasonLost
        case .pagesOver: return ProfileV3Strings.passportReasonPagesOver
        case .validityExpired: return ProfileV3Strings.passportReasonValidityExpired
        case .damaged: return ProfileV3Strings.passportReasonDamaged
        }
    }
}

struct ProfileV3PassportField: Equatable {
    var holderName: String
    var countryName: String
    var countryNativeName: String?
    var passport: ProfileV3Passport?
    var hasHistory = false
    var rescan: ProfileV3Directive?
    var howUsed: ProfileV3Directive?
}

public enum ProfileV3PassportSide: String, CaseIterable, Sendable {
    case front
    case back
}

struct ProfileV3PassportScanPage: Equatable {
    var title: String?
    var subtitle: String?
}

struct ProfileV3PassportScan: Equatable {
    var title: String?
    var howUsed: ProfileV3Directive?
    var front = ProfileV3PassportScanPage()
    var back = ProfileV3PassportScanPage()
    var next: ProfileV3Directive?

    static let fallback = ProfileV3PassportScan(
        howUsed: ProfileV3Directive(go: ProfileV3PassportRoute.howUsed),
        next: ProfileV3Directive(go: ProfileV3PassportRoute.reason)
    )
}

struct ProfileV3PassportReasonOption: Identifiable, Equatable {
    let value: String
    let label: String

    var id: String { value }
}

struct ProfileV3PassportReasonScreen: Equatable {
    var title: String?
    var subtitle: String?
    var howUsed: ProfileV3Directive?
    var options: [ProfileV3PassportReasonOption]
    var ctaTitle: String?

    static let fallback = ProfileV3PassportReasonScreen(
        howUsed: ProfileV3Directive(go: ProfileV3PassportRoute.howUsed),
        options: ProfileV3PassportChangeReason.allCases.map {
            ProfileV3PassportReasonOption(value: $0.rawValue, label: $0.title)
        }
    )
}

struct ProfileV3PassportHowUsedStep: Identifiable, Equatable {
    let id: Int
    let icon: String?
    let title: String
    let body: String
}

struct ProfileV3PassportHowUsed: Equatable {
    let title: String
    let steps: [ProfileV3PassportHowUsedStep]
    var scanLabel: String?
    var scan: ProfileV3Directive?
}

enum ProfileV3PassportRoute {
    static let update = "passport_update"
    static let reason = "passport_reason"
    static let howUsed = "passport_how_used"
}
