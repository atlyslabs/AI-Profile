import ATUIKit
import SwiftUI

struct ProfileV3TagLabel: View {
    enum Style {
        case solid(Color)
        case gradient
    }

    let text: String
    var icon: Image?
    var style: Style = .solid(Color(at: .pureBlack))

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s6) {
            if let icon {
                icon
                    .profileV3Icon(ProfileV3Theme.Icon.sm)
            }
            Text(text)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
        }
        .foregroundStyle(foreground)
    }

    private var foreground: AnyShapeStyle {
        switch style {
        case .solid(let color):
            return AnyShapeStyle(color)
        case .gradient:
            return AnyShapeStyle(ProfileV3Theme.tagGradient)
        }
    }
}

extension ProfileV3TagLabel {
    static func kyc(_ text: String) -> ProfileV3TagLabel {
        ProfileV3TagLabel(text: text, icon: ATIcon.SwiftUIImage.error, style: .gradient)
    }
}

#if DEBUG
#Preview("Tag labels") {
    VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s16) {
        ProfileV3TagLabel(text: ProfileV3Strings.settings)
        ProfileV3TagLabel(text: "Airlines")
        ProfileV3TagLabel.kyc("KYC expired on 23 Dec, 2027")
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
