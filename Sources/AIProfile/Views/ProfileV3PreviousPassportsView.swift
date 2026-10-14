import ATUIKit
import SwiftUI

struct ProfileV3PreviousPassportsView: View {
    let holderName: String
    let countryName: String
    var countryNativeName: String?
    let passports: [ProfileV3Passport]
    var phase: ProfileV3LoadPhase = .loaded
    let onBack: () -> Void
    var onRetry: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ProfileV3Theme.passportScreenGradient.ignoresSafeArea())
    }

    @ViewBuilder
    private var content: some View {
        if phase != .loaded {
            ProfileV3LoadStateView(phase: phase, retry: onRetry)
        } else if passports.isEmpty {
            emptyState
        } else {
            list
        }
    }

    private var list: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ProfileV3Theme.Sizes.Passport.listSpacing) {
                ForEach(Array(passports.enumerated()), id: \.element.id) { index, passport in
                    ProfileV3PassportCard(
                        holderName: holderName,
                        countryName: countryName,
                        countryNativeName: countryNativeName,
                        content: .details(passport),
                        showsStatusBadge: true
                    )
                    if index == 0, passports.count > 1 {
                        Rectangle()
                            .fill(Color(at: .borderLightLight100))
                            .frame(height: ProfileV3Theme.Stroke.hairline)
                    }
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Passport.listTop)
            .padding(.bottom, ProfileV3Theme.Sizes.Passport.listBottom)
        }
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
        ProfileV3BackTagHeader(title: ProfileV3Strings.previousPassports, onBack: onBack)
    }
}

#if DEBUG
#Preview("Previous passports") {
    ProfileV3PreviousPassportsView(
        holderName: "alex r.",
        countryName: ProfileV3Strings.passportCountryIndia,
        countryNativeName: ProfileV3Strings.passportCountryIndiaNative,
        passports: ProfileV3PassportFixtures.history,
        onBack: {}
    )
}

#Preview("Previous passports · empty") {
    ProfileV3PreviousPassportsView(
        holderName: "alex r.",
        countryName: ProfileV3Strings.passportCountryIndia,
        passports: [],
        onBack: {}
    )
}

#Preview("Previous passports · loading") {
    ProfileV3PreviousPassportsView(
        holderName: "alex r.",
        countryName: ProfileV3Strings.passportCountryIndia,
        passports: [],
        phase: .loading,
        onBack: {}
    )
}

#Preview("Previous passports · failed") {
    ProfileV3PreviousPassportsView(
        holderName: "alex r.",
        countryName: ProfileV3Strings.passportCountryIndia,
        passports: [],
        phase: .failed,
        onBack: {},
        onRetry: {}
    )
}
#endif
