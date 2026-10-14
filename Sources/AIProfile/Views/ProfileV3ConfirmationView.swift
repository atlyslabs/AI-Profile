import ATUIKit
import SwiftUI

struct ProfileV3ConfirmationView: View {
    enum Style {
        case neutral
        case destructive

        var circle: Color {
            switch self {
            case .neutral: return ProfileV3Theme.Palette.neutralSoft
            case .destructive: return ProfileV3Theme.Palette.destructiveSoft
            }
        }

        var glyph: Color {
            switch self {
            case .neutral: return Color(at: .pureBlack)
            case .destructive: return ProfileV3Theme.Palette.destructiveGlyph
            }
        }
    }

    let icon: Image
    let style: Style
    let title: String
    var message: String?
    let primaryTitle: String
    let secondaryTitle: String
    var isPrimaryLoading = false
    let onBack: () -> Void
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            ZStack(alignment: .top) {
                VStack(spacing: ProfileV3Theme.Sizes.Confirmation.iconSpacing) {
                    iconCircle
                    VStack(spacing: ProfileV3Theme.Sizes.Confirmation.textSpacing) {
                        Text(title)
                            .typoGraphy(.H6InterMedium18)
                            .foregroundStyle(Color(at: .pureBlack))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: ProfileV3Theme.Sizes.Confirmation.titleWidth)
                        if let message {
                            Text(message)
                                .typoGraphy(.B2InterMedium12)
                                .foregroundStyle(Color(at: .neutralGrey400))
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width: ProfileV3Theme.Sizes.Confirmation.bodyWidth)
                        }
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, ProfileV3Theme.Sizes.Confirmation.top)
                HStack {
                    ProfileV3CircleIconButton.back(action: onBack)
                        .disabled(isPrimaryLoading)
                    Spacer()
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Sizes.sheetHeaderTop)
            }
            VStack(spacing: ProfileV3Theme.Sizes.Confirmation.buttonSpacing) {
                ProfileV3ContinueButton(
                    title: primaryTitle,
                    tint: ProfileV3Theme.Palette.destructive,
                    isLoading: isPrimaryLoading,
                    action: onPrimary
                )
                ProfileV3ContinueButton(title: secondaryTitle, isEnabled: !isPrimaryLoading, action: onSecondary)
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Confirmation.buttonsTop)
            .padding(.bottom, ProfileV3Theme.Sizes.ctaBarBottom)
        }
        .background(Color(at: .pureWhite))
    }

    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(style.circle)
                .frame(
                    width: ProfileV3Theme.Sizes.Confirmation.iconCircle,
                    height: ProfileV3Theme.Sizes.Confirmation.iconCircle
                )
            icon
                .profileV3Icon(ProfileV3Theme.Icon.md)
                .foregroundStyle(style.glyph)
        }
        .accessibilityHidden(true)
    }
}

extension ProfileV3ConfirmationView {
    static func logout(
        isLoggingOut: Bool = false,
        onBack: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: ATIcon.SwiftUIImage.logout,
            style: .neutral,
            title: ProfileV3Strings.logoutConfirmTitle,
            primaryTitle: ProfileV3Strings.logout,
            secondaryTitle: ProfileV3Strings.staySignedIn,
            isPrimaryLoading: isLoggingOut,
            onBack: onBack,
            onPrimary: onLogout,
            onSecondary: onBack
        )
    }

    static func deleteAccount(
        onBack: @escaping () -> Void,
        onProceed: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: ATIcon.SwiftUIImage.delete,
            style: .destructive,
            title: ProfileV3Strings.deleteConfirmTitle,
            message: ProfileV3Strings.deleteConfirmBody,
            primaryTitle: ProfileV3Strings.proceedToDelete,
            secondaryTitle: ProfileV3Strings.dontDelete,
            onBack: onBack,
            onPrimary: onProceed,
            onSecondary: onBack
        )
    }
}

#if DEBUG
#Preview("Logout") {
    ProfileV3ConfirmationView.logout(onBack: {}, onLogout: {})
}

#Preview("Logout · signing out") {
    ProfileV3ConfirmationView.logout(isLoggingOut: true, onBack: {}, onLogout: {})
}

#Preview("Delete account") {
    ProfileV3ConfirmationView.deleteAccount(onBack: {}, onProceed: {})
}
#endif
