import ATUIKit
import SwiftUI

struct ProfileV3StatusDot: View {
    enum Kind {
        case complete
        case pending
    }

    let kind: Kind

    var body: some View {
        Group {
            switch kind {
            case .complete:
                ProfileV3Vector.statusComplete.image
                    .profileV3Icon(ProfileV3Theme.Sizes.statusDot)
                    .foregroundStyle(Color(at: .accentEmerald500))
            case .pending:
                Circle()
                    .strokeBorder(ProfileV3Theme.pendingRingGradient, lineWidth: ProfileV3Theme.Stroke.hairline)
                    .overlay(
                        Circle()
                            .fill(Color(at: .pureBlack))
                            .frame(
                                width: ProfileV3Theme.Sizes.statusDotCore,
                                height: ProfileV3Theme.Sizes.statusDotCore
                            )
                    )
                    .frame(width: ProfileV3Theme.Sizes.statusDot, height: ProfileV3Theme.Sizes.statusDot)
            }
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Status dots") {
    HStack(spacing: ProfileV3Theme.Space.s16) {
        ProfileV3StatusDot(kind: .complete)
        ProfileV3StatusDot(kind: .pending)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
