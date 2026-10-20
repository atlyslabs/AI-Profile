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
    var metrics = Metrics.standard
    let onBack: () -> Void
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    struct Metrics {
        var top = ProfileV3Theme.Sizes.Confirmation.top
        var iconSpacing = ProfileV3Theme.Sizes.Confirmation.iconSpacing
        var bodyWidth = ProfileV3Theme.Sizes.Confirmation.bodyWidth
        var buttonsTop = ProfileV3Theme.Sizes.Confirmation.buttonsTop
        var showsSubject = false

        static let standard = Metrics()
        static let subject = Metrics(
            top: ProfileV3Theme.Sizes.Confirmation.subjectTop,
            iconSpacing: ProfileV3Theme.Sizes.Confirmation.subjectIconSpacing,
            bodyWidth: ProfileV3Theme.Sizes.Confirmation.subjectWidth,
            buttonsTop: ProfileV3Theme.Sizes.Confirmation.subjectButtonsTop,
            showsSubject: true
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            ZStack(alignment: .top) {
                VStack(spacing: metrics.iconSpacing) {
                    iconCircle
                    VStack(spacing: ProfileV3Theme.Sizes.Confirmation.textSpacing) {
                        Text(title)
                            .typoGraphy(.H6InterMedium18)
                            .foregroundStyle(Color(at: .pureBlack))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: ProfileV3Theme.Sizes.Confirmation.titleWidth)
                        if let message {
                            messageText(message)
                                .frame(width: metrics.bodyWidth)
                        }
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, metrics.top)
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
            .padding(.top, metrics.buttonsTop)
            .padding(.bottom, ProfileV3Theme.Sizes.ctaBarBottom)
        }
        .background(Color(at: .pureWhite))
    }

    @ViewBuilder
    private func messageText(_ message: String) -> some View {
        if metrics.showsSubject {
            Text(message)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.credentialDeleteSubject))
                .lineLimit(1)
                .truncationMode(.tail)
        } else {
            Text(message)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .neutralGrey400))
                .fixedSize(horizontal: false, vertical: true)
        }
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

    static func deleteLogin(
        subject: String?,
        isDeleting: Bool,
        onBack: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: ATIcon.SwiftUIImage.delete,
            style: .destructive,
            title: ProfileV3Strings.credentialDeleteConfirm,
            message: subject,
            primaryTitle: ProfileV3Strings.proceedToDelete,
            secondaryTitle: ProfileV3Strings.dontDelete,
            isPrimaryLoading: isDeleting,
            metrics: .subject,
            onBack: onBack,
            onPrimary: onDelete,
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

#Preview("Delete login") {
    ProfileV3ConfirmationView.deleteLogin(
        subject: "hdfcbank.in/ways-to-bank/digital-banking",
        isDeleting: false,
        onBack: {},
        onDelete: {}
    )
}
#endif
