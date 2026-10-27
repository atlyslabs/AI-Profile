import ATUIKit
import SwiftUI

struct ProfileV3PreviousPassportsView: View {
    let title: String
    let screen: ProfileV3PreviousPassports?
    var phase: ProfileV3LoadPhase = .loaded
    let onBack: () -> Void
    var onRetry: () -> Void = {}

    @State private var headerPin = ProfileV3HeaderPin()

    private typealias Passport = ProfileV3Theme.Sizes.Passport

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
    }

    @ViewBuilder
    private var content: some View {
        if phase != .loaded {
            ProfileV3LoadStateView(phase: phase, retry: onRetry)
        } else if let screen, !screen.passports.isEmpty {
            list(screen)
        } else {
            emptyState
        }
    }

    private func list(_ screen: ProfileV3PreviousPassports) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Passport.listSpacing) {
                ForEach(Array(screen.passports.enumerated()), id: \.element.id) { index, passport in
                    ProfileV3PassportCard(
                        holderName: passport.holderName,
                        countryName: passport.countryName,
                        countryNativeName: passport.countryNativeName,
                        labels: screen.labels,
                        content: .details(passport),
                        showsStatusBadge: true
                    )
                    if index == 0, screen.passports.count > 1 {
                        ProfileV3HorizontalRule()
                            .stroke(
                                ProfileV3Theme.Palette.passportListDivider,
                                style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.hairline, dash: Passport.listDividerDash)
                            )
                            .frame(height: ProfileV3Theme.Stroke.hairline)
                            .accessibilityHidden(true)
                    }
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Passport.listTop)
            .padding(.bottom, Passport.listBottom)
            .profileV3HeaderFadeAnchor(headerPin)
        }
        .profileV3HeaderFade(headerPin)
        .scrollBounceBehavior(.basedOnSize)
    }

    private var emptyState: some View {
        ProfileV3EmptyState(
            icon: ATIcon.SwiftUIImage.contactPage,
            title: ProfileV3Strings.noPreviousPassportsTitle,
            subtitle: ProfileV3Strings.noPreviousPassportsSubtitle
        )
        .frame(width: ProfileV3Theme.Sizes.emptyStateTextWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, ProfileV3Theme.Sizes.emptyStateTop)
    }

    private var header: some View {
        ProfileV3BackTagHeader(title: title, onBack: onBack)
    }
}

#if DEBUG
#Preview("Previous passports") {
    ProfileV3PreviousPassportsView(
        title: "PREVIOUS PASSPORTS",
        screen: ProfileV3PassportFixtures.previous,
        onBack: {}
    )
}

#Preview("Previous passports · empty") {
    ProfileV3PreviousPassportsView(
        title: "PREVIOUS PASSPORTS",
        screen: ProfileV3PreviousPassports(title: "PREVIOUS PASSPORTS", labels: .card, passports: []),
        onBack: {}
    )
}

#Preview("Previous passports · loading") {
    ProfileV3PreviousPassportsView(
        title: "PREVIOUS PASSPORTS",
        screen: nil,
        phase: .loading,
        onBack: {}
    )
}

#Preview("Previous passports · failed") {
    ProfileV3PreviousPassportsView(
        title: "PREVIOUS PASSPORTS",
        screen: nil,
        phase: .failed,
        onBack: {},
        onRetry: {}
    )
}
#endif
