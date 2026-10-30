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

    let icon: Image?
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
        static let plain = Metrics(
            top: ProfileV3Theme.Sizes.Confirmation.plainTop,
            buttonsTop: ProfileV3Theme.Sizes.Confirmation.plainButtonsTop
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            ZStack(alignment: .top) {
                VStack(spacing: metrics.iconSpacing) {
                    if let icon {
                        iconCircle(icon)
                    }
                    ProfileV3ConfirmationCopy(
                        title: title,
                        message: message,
                        messageStyle: metrics.showsSubject ? .subject : .body,
                        messageWidth: metrics.bodyWidth
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, metrics.top)
                ProfileV3SheetControls(onBack: onBack)
                    .disabled(isPrimaryLoading)
                    .padding(.top, ProfileV3Theme.Sizes.sheetHeaderTop)
            }
            ProfileV3ConfirmationActions(
                primaryTitle: primaryTitle,
                secondaryTitle: secondaryTitle,
                isPrimaryLoading: isPrimaryLoading,
                onPrimary: onPrimary,
                onSecondary: onSecondary
            )
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, metrics.buttonsTop)
            .padding(.bottom, ProfileV3Theme.Sizes.ctaBarBottom)
        }
        .background(Color(at: .pureWhite))
    }

    private func iconCircle(_ icon: Image) -> some View {
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

struct ProfileV3ConfirmationCopy: View {
    enum MessageStyle {
        case body
        case subject
    }

    let title: String
    var message: String?
    var messageStyle = MessageStyle.body
    var messageWidth = ProfileV3Theme.Sizes.Confirmation.bodyWidth
    var titleColor = Color(at: .pureBlack)
    var messageColor = Color(at: .neutralGrey400)

    var body: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Confirmation.textSpacing) {
            if !title.isEmpty {
                Text(title)
                    .typoGraphy(.H6InterMedium18)
                    .foregroundStyle(titleColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: ProfileV3Theme.Sizes.Confirmation.titleWidth)
            }
            if let message {
                messageText(message)
                    .frame(width: messageWidth)
            }
        }
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private func messageText(_ message: String) -> some View {
        switch messageStyle {
        case .subject:
            Text(message)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.credentialDeleteSubject))
                .lineLimit(1)
                .truncationMode(.tail)
        case .body:
            Text(message)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(messageColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ProfileV3ConfirmationActions: View {
    let primaryTitle: String
    let secondaryTitle: String
    var isPrimaryLoading = false
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Confirmation.buttonSpacing) {
            if !primaryTitle.isEmpty {
                ProfileV3ContinueButton(
                    title: primaryTitle,
                    tint: ProfileV3Theme.Palette.destructive,
                    isLoading: isPrimaryLoading,
                    action: onPrimary
                )
            }
            if !secondaryTitle.isEmpty {
                ProfileV3ContinueButton(title: secondaryTitle, isEnabled: !isPrimaryLoading, action: onSecondary)
            }
        }
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
        _ confirm: ProfileV3DeleteAccountConfirm,
        isDeleting: Bool = false,
        onBack: @escaping () -> Void,
        onProceed: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: ATIcon.SwiftUIImage.delete,
            style: .destructive,
            title: confirm.title,
            message: confirm.warning.nonEmpty,
            primaryTitle: confirm.proceedLabel,
            secondaryTitle: confirm.cancelLabel,
            isPrimaryLoading: isDeleting,
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

    static func deleteProgrammes(
        count: Int,
        isDeleting: Bool,
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: nil,
            style: .destructive,
            title: ProfileV3Strings.deleteProgrammesConfirm(count),
            primaryTitle: ProfileV3Strings.confirmDeleteProgrammes,
            secondaryTitle: ProfileV3Strings.cancel,
            isPrimaryLoading: isDeleting,
            metrics: .plain,
            onBack: onBack,
            onPrimary: onConfirm,
            onSecondary: onBack
        )
    }

    static func deletePastTrip(
        _ confirm: ProfileV3TripDeleteConfirm,
        isDeleting: Bool,
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: ATIcon.SwiftUIImage.delete,
            style: .destructive,
            title: confirm.title,
            primaryTitle: confirm.confirmLabel,
            secondaryTitle: confirm.cancelLabel,
            isPrimaryLoading: isDeleting,
            onBack: onBack,
            onPrimary: onConfirm,
            onSecondary: onBack
        )
    }

    static func deleteRule(
        _ confirm: ProfileV3CustomRulesField.DeleteConfirm,
        isDeleting: Bool,
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: nil,
            style: .destructive,
            title: confirm.title,
            primaryTitle: confirm.confirmLabel,
            secondaryTitle: confirm.cancelLabel,
            isPrimaryLoading: isDeleting,
            metrics: .plain,
            onBack: onBack,
            onPrimary: onConfirm,
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
    ProfileV3ConfirmationView.deleteAccount(ProfileV3Fixtures.deleteAccountConfirm, onBack: {}, onProceed: {})
}

#Preview("Delete programs") {
    ProfileV3ConfirmationView.deleteProgrammes(count: 2, isDeleting: false, onBack: {}, onConfirm: {})
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
