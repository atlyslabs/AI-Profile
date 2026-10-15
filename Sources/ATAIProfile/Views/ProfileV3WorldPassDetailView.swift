import ATUIKit
import SwiftUI

struct ProfileV3WorldPassDetailView: View {
    let pass: ProfileV3WorldPass
    var isGlobeAnimating = true
    var globePose: ProfileV3GlobePose?
    var onGlobeSphere: ((ProfileV3GlobeSphere) -> Void)?
    var onAddTraveller: (() -> Void)?
    var onPastTrips: ((_ startsAdding: Bool) -> Void)?

    var body: some View {
        let flagCodes = pass.uniqueVisitedCountryCodes
        ZStack {
            streak
            VStack(spacing: 0) {
                ProfileV3WorldPassHeader()
                    .padding(.top, ProfileV3Theme.Space.s30)
                ProfileV3InteractiveGlobe(
                    visitedCountryCodes: flagCodes,
                    isAnimating: isGlobeAnimating,
                    pose: globePose,
                    onSphere: onGlobeSphere
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: ProfileV3Theme.Space.s16) {
                    Text(pass.holderName)
                        .typoGraphy(.H7InterMedium16)
                        .foregroundStyle(Color(at: .pureWhite))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ProfileV3Theme.Sizes.Detail.statsHorizontal)
                    ProfileV3PassNumber(
                        number: pass.memberNumber,
                        maxWidth: ProfileV3Theme.Sizes.worldPassNumberMaxWidth
                    )
                    visitedCountries(flagCodes)
                }
                statsGrid
                    .padding(.top, ProfileV3Theme.Sizes.Detail.statsTop)
                    .padding(.horizontal, ProfileV3Theme.Sizes.Detail.statsHorizontal)
                    .padding(.bottom, ProfileV3Theme.Sizes.Detail.bottom)
            }
        }
    }

    private var streak: some View {
        LinearGradient(
            colors: [.clear, ProfileV3Theme.Palette.cardStreak, .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func visitedCountries(_ codes: [String]) -> some View {
        if ProfileV3FeatureFlags.isPastTripsEnabled, let onPastTrips {
            if codes.isEmpty {
                ProfileV3AddPastTripsPill { onPastTrips(true) }
            } else {
                Button { onPastTrips(false) } label: {
                    flagsPill(codes, showsAddIcon: true)
                }
                .buttonStyle(.profileV3Pressable(.selection))
                .accessibilityLabel(ProfileV3Strings.visitedCountries(codes.count))
            }
        } else if !codes.isEmpty {
            flagsPill(codes, showsAddIcon: false)
        }
    }

    private func flagsPill(_ codes: [String], showsAddIcon: Bool) -> some View {
        let hiddenFlagCount = max(codes.count - ProfileV3Theme.Counts.detailPillMaxFlags, 0)
        return HStack(spacing: ProfileV3Theme.Space.s14) {
            HStack(spacing: ProfileV3Theme.Space.s8) {
                HStack(spacing: ProfileV3Theme.Sizes.Detail.pillFlagOverlap) {
                    ForEach(codes.prefix(ProfileV3Theme.Counts.detailPillMaxFlags), id: \.self) { code in
                        flag(for: code)
                    }
                }
                if hiddenFlagCount > 0 {
                    Text(ProfileV3Strings.moreCount(hiddenFlagCount))
                        .typoGraphy(.H6InterSemibold18)
                        .foregroundStyle(ProfileV3Theme.Palette.statLabel)
                }
            }
            if showsAddIcon {
                addIcon
            } else if ProfileV3FeatureFlags.isPassAddTravellerEnabled, let onAddTraveller {
                Button(action: onAddTraveller) { addIcon }
                    .buttonStyle(.plain)
                    .accessibilityLabel(ProfileV3Strings.addTraveller)
            }
        }
        .padding(.leading, ProfileV3Theme.Space.s12)
        .padding(.trailing, ProfileV3Theme.Space.s12)
        .frame(height: ProfileV3Theme.Control.tapTarget)
        .background(Capsule().fill(ProfileV3Theme.detailPillGradient))
        .shadow(
            color: ProfileV3Theme.Palette.shadow,
            radius: ProfileV3Theme.Shadow.cardRadius,
            y: ProfileV3Theme.Shadow.chipY
        )
    }

    private var addIcon: some View {
        ATIcon.SwiftUIImage.addCircle
            .profileV3Icon(ProfileV3Theme.Sizes.PastTripsPill.icon)
            .foregroundStyle(Color(at: .pureWhite))
    }

    @ViewBuilder
    private func flag(for code: String) -> some View {
        if let country = ATCountry(isoCode: code) {
            ATCountryFlagView(country: country)
                .frame(width: ProfileV3Theme.Sizes.Detail.pillFlag, height: ProfileV3Theme.Sizes.Detail.pillFlag)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color(at: .neutralGrey600))
                .frame(width: ProfileV3Theme.Sizes.Detail.pillFlag, height: ProfileV3Theme.Sizes.Detail.pillFlag)
        }
    }

    private var statCells: [ProfileV3StatCell] {
        guard pass.stats.isEmpty, ProfileV3FeatureFlags.isPastTripsEnabled else {
            return pass.stats.map { ProfileV3StatCell(id: $0.key.rawValue, label: $0.label, value: $0.displayValue) }
        }
        return ProfileV3StatCell.placeholders
    }

    private var statRows: [[ProfileV3StatCell]] {
        let all = statCells
        guard all.count > ProfileV3Theme.Counts.detailStatsFirstRow else { return all.isEmpty ? [] : [all] }
        return [
            Array(all.prefix(ProfileV3Theme.Counts.detailStatsFirstRow)),
            Array(all.dropFirst(ProfileV3Theme.Counts.detailStatsFirstRow))
        ]
    }

    private func alignment(at index: Int, in count: Int) -> HorizontalAlignment {
        guard count > 1 else { return .center }
        return index == count - 1 ? .trailing : .leading
    }

    private var statsGrid: some View {
        VStack(spacing: ProfileV3Theme.Space.s32) {
            ForEach(Array(statRows.enumerated()), id: \.offset) { _, row in
                HStack {
                    ForEach(Array(row.enumerated()), id: \.element.id) { index, stat in
                        ProfileV3StatItem(
                            label: stat.label,
                            value: stat.value,
                            alignment: alignment(at: index, in: row.count)
                        )
                        if index < row.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

private struct ProfileV3StatCell: Identifiable {
    let id: String
    let label: String
    let value: String

    static let placeholders = [
        (ProfileV3TravelStat.Key.flights, ProfileV3Strings.statFlights),
        (.distance, ProfileV3Strings.statDistance),
        (.countries, ProfileV3Strings.statCountries),
        (.airports, ProfileV3Strings.statAirports),
        (.airlines, ProfileV3Strings.statAirlines)
    ].map { ProfileV3StatCell(id: $0.0.rawValue, label: $0.1, value: ProfileV3Strings.statPlaceholder) }
}

private struct ProfileV3StatItem: View {
    let label: String
    let value: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: ProfileV3Theme.Space.s8) {
            Text(label)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
                .foregroundStyle(ProfileV3Theme.Palette.statLabel)
            Text(value)
                .typoGraphy(.H3InterMedium28)
                .foregroundStyle(Color(at: .pureWhite))
        }
    }
}

#if DEBUG
@MainActor
private func profileV3DetailPreview(_ pass: ProfileV3WorldPass) -> some View {
    ProfileV3WorldPassDetailView(pass: pass)
    .background(Color(at: .pureBlack))
    .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.Detail.cornerRadius, style: .continuous))
    .aspectRatio(ProfileV3Theme.Sizes.Detail.aspectRatio, contentMode: .fit)
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}

private func profileV3PreviewPass(codes: [String], stats: [ProfileV3TravelStat]) -> ProfileV3WorldPass {
    let base = ProfileV3Fixtures.worldPass
    return ProfileV3WorldPass(
        id: base.id,
        holderName: base.holderName,
        memberNumber: base.memberNumber,
        kycStatus: base.kycStatus,
        visitedCountryCodes: codes,
        stats: stats
    )
}

#Preview("World Pass detail") {
    profileV3DetailPreview(ProfileV3Fixtures.worldPass)
}

#Preview("World Pass detail · no flags or stats") {
    profileV3DetailPreview(profileV3PreviewPass(codes: [], stats: []))
}

#Preview("World Pass detail · flag overflow") {
    profileV3DetailPreview(
        profileV3PreviewPass(
            codes: ["IN", "AE", "SG", "TH", "JP", "FR", "GB", "US", "DE", "IT"],
            stats: ProfileV3Fixtures.worldPass.stats
        )
    )
}
#endif
