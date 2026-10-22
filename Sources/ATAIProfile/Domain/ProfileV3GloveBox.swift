import Foundation

struct ProfileV3GloveBox: Equatable {
    enum Stage: Equatable {
        case intro(ProfileV3GloveBoxIntro)
        case home(ProfileV3GloveBoxHome)
    }

    let title: String
    var stage: Stage
}

struct ProfileV3GloveBoxIntro: Hashable {
    enum Status: Hashable {
        case locked
        case warmingUp
    }

    enum Action: Hashable {
        case completeKYC
        case activate
    }

    let title: String
    let subtitle: String
    let status: Status
    let statusLabel: String
    let actionTitle: String
    let action: Action
}

struct ProfileV3GloveBoxHome: Equatable {
    var email: ProfileV3GloveBoxEmailSection
    var phone: ProfileV3GloveBoxPhoneSection
    var card: ProfileV3GloveBoxCardSection
}

struct ProfileV3GloveBoxBadge: Equatable {
    enum Tone: Equatable {
        case live
        case pending
    }

    let label: String
    let tone: Tone
}

struct ProfileV3GloveBoxNumber: Equatable {
    let value: String
    var countryCode: String?
    var isCopyable = false
}

enum ProfileV3GloveBoxGlyph: Equatable {
    case mail
    case seen
    case calendar
    case done
}

struct ProfileV3GloveBoxMeta: Equatable {
    var glyphs: [ProfileV3GloveBoxGlyph] = []
    let label: String
    var dateLabel: String?
}

struct ProfileV3GloveBoxEmailSection: Equatable {
    let title: String
    var badge: ProfileV3GloveBoxBadge?
    let address: String
    let about: String
    let forwardingLabel: String
    var forwardingAddress: String?
    let emails: [ProfileV3GloveBoxEmail]
    var sampleLabel: String?
    var viewAllTitle: String?
    let listTitle: String
}

struct ProfileV3GloveBoxEmail: Identifiable, Equatable {
    let id: String
    let sender: String
    let summary: String
    var logoURL: URL?
    var attention: String?
    var meta: ProfileV3GloveBoxMeta?
    var badge: String?
    var note: String?
    var followUpTitle: String?
}

struct ProfileV3GloveBoxPhoneSection: Equatable {
    struct Headline: Equatable {
        let lead: String
        let emphasis: String
        let trail: String
    }

    struct Trip: Equatable {
        let label: String
        let number: ProfileV3GloveBoxNumber
        var badge: ProfileV3GloveBoxBadge?
    }

    let title: String
    var badge: ProfileV3GloveBoxBadge?
    let number: ProfileV3GloveBoxNumber
    var headline: Headline?
    let about: String
    var trip: Trip?
    let calls: [ProfileV3GloveBoxCall]
    var sampleLabel: String?
    var viewAllTitle: String?
    let listTitle: String
}

struct ProfileV3GloveBoxCall: Identifiable, Equatable {
    enum Recording: Equatable {
        case audio(duration: String, speed: String)
        case missing(String)
    }

    let id: String
    let title: String
    let summary: String
    var logoURL: URL?
    var meta: ProfileV3GloveBoxMeta?
    let recording: Recording
    var badge: String?
    var note: String?
    var followUpTitle: String?
}

struct ProfileV3GloveBoxCardSection: Equatable {
    struct Card: Equatable {
        let lastFour: String
        let holder: String
        let expiryLabel: String
        let cvcLabel: String
        let nameLabel: String
    }

    struct Stat: Identifiable, Equatable {
        let id: String
        let value: String
        let label: String
    }

    struct Fact: Identifiable, Equatable {
        let id: String
        let label: String
        let value: String
    }

    struct PayOption: Identifiable, Equatable {
        enum Kind: Equatable {
            case atlys
            case link
        }

        let id: String
        let title: String
        let body: String
        let kind: Kind
    }

    struct LinkedCard: Equatable {
        let label: String
        var logoURL: URL?
    }

    let title: String
    var badge: ProfileV3GloveBoxBadge?
    let card: Card
    let protectedNotice: String
    let stats: [Stat]
    let facts: [Fact]
    let payTitle: String
    let payBody: String
    let payOptions: [PayOption]
    var selectedPayOptionID: String?
    var linkedCard: LinkedCard?
    let addCardTitle: String
    let secureNote: String
    let transactions: [ProfileV3GloveBoxTransaction]
    let emptyTitle: String
    let emptyBody: String
    var viewAllTitle: String?
    let listTitle: String
}

struct ProfileV3GloveBoxTransaction: Identifiable, Equatable {
    enum Outcome: Equatable {
        case approved
        case blocked
    }

    let id: String
    let title: String
    let summary: String
    let amount: String
    let outcome: Outcome
    let outcomeLabel: String
    var note: String?
    var followUpTitle: String?
}
