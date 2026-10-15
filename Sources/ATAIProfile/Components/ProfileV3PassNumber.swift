import ATUIKit
import SwiftUI

struct ProfileV3PassNumber: View {
    enum Surface {
        case dark
        case light
    }

    let number: String
    var surface: Surface = .dark
    var maxWidth: CGFloat?

    var body: some View {
        if let number = number.nonEmpty {
            Text(number)
                .font(
                    .custom(
                        ProfileV3Theme.Typography.worldPassNumberFont,
                        size: ProfileV3Theme.Typography.worldPassNumberSize
                    )
                )
                .tracking(ProfileV3Theme.Typography.worldPassNumberTracking)
                .lineLimit(1)
                .minimumScaleFactor(ProfileV3Theme.Typography.worldPassNumberMinScale)
                .frame(maxWidth: maxWidth)
                .foregroundStyle(gradient)
                .accessibilityLabel(ProfileV3Strings.passNumberLabel(number))
        }
    }

    private var gradient: LinearGradient {
        switch surface {
        case .dark:
            return ProfileV3Theme.worldPassNumberOnDarkGradient
        case .light:
            return ProfileV3Theme.worldPassNumberGradient
        }
    }
}

#if DEBUG
#Preview("Pass number") {
    VStack(spacing: 0) {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            ProfileV3PassNumber(number: "6190001")
            ProfileV3PassNumber(number: "")
        }
        .frame(maxWidth: .infinity)
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureBlack))
        ProfileV3PassNumber(number: "6190001", surface: .light)
            .frame(maxWidth: .infinity)
            .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
            .background(Color(at: .pureWhite))
    }
}
#endif
