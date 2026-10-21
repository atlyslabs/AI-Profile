import Foundation

struct ProfileV3GloveBox: Equatable {
    enum Stage: Equatable {
        case intro(ProfileV3GloveBoxIntro)
        case inbox(ProfileV3GloveBoxInbox)
    }

    let title: String
    var stage: Stage
}

struct ProfileV3GloveBoxIntro: Equatable {
    enum Action: Equatable {
        case completeKYC
        case activate
    }

    let title: String
    let subtitle: String
    let actionTitle: String
    let action: Action
}

struct ProfileV3GloveBoxInbox: Equatable {
    let address: String
    let about: String
    let forwardingLabel: String
    var forwardingAddress: String?
    let recentTitle: String
    let emails: [ProfileV3GloveBoxEmail]
    let emptyTitle: String
    let emptyBody: String
}

struct ProfileV3GloveBoxEmail: Identifiable, Equatable {
    enum Glyph: Equatable {
        case mail
        case seen
        case calendar
        case done
    }

    let id: String
    let sender: String
    let summary: String
    var logoURL: URL?
    var glyphs: [Glyph] = []
    let statusLabel: String
    var dateLabel: String?
    var needsAttention = false
    var badge: String?
    var note: String?
    var followUpTitle: String?
}
