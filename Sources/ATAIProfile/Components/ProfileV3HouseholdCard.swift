import ATUIKit
import SwiftUI

struct ProfileV3HouseholdCard: View {
    static let selectionID = "profile_v3_household"

    let isSelected: Bool
    var collapseProgress: CGFloat = 0
    let onSelect: () -> Void
    let onAdd: () -> Void

    @State private var adds = 0

    private typealias Household = ProfileV3Theme.Sizes.Household

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius, style: .continuous)
    }

    var body: some View {
        Button(action: tap) {
            VStack(spacing: 0) {
                plus
                Text(ProfileV3Strings.householdTitle)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureBlack))
                    .padding(.top, Household.titleTop)
                Text(ProfileV3Strings.householdSubtitle)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .frame(width: Household.subtitleWidth)
                    .padding(.top, Household.subtitleTop)
            }
            .multilineTextAlignment(.center)
            .padding(.top, Household.contentTop)
            .frame(
                width: ProfileV3Theme.Sizes.worldPassWidth,
                height: ProfileV3Theme.Sizes.worldPassHeight,
                alignment: .top
            )
            .overlay {
                shape.strokeBorder(
                    Color(at: .borderLightLight200),
                    style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.hairline, dash: Household.dash)
                )
            }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .opacity(1 - ProfileV3Theme.ramp(collapseProgress, from: 0, to: ProfileV3Theme.Motion.collapseChromeFadeEnd))
        .allowsHitTesting(collapseProgress < ProfileV3Theme.Motion.collapseInteractionLimit)
        .sensoryFeedback(.impact(weight: .light), trigger: adds)
        .accessibilityLabel(ProfileV3Strings.householdTitle)
        .accessibilityHint(ProfileV3Strings.householdSubtitle)
    }

    private var plus: some View {
        ZStack {
            Circle()
                .strokeBorder(Color(at: .pureBlack), lineWidth: ProfileV3Theme.Stroke.hairline)
            Capsule()
                .fill(Color(at: .pureBlack))
                .frame(width: Household.plusGlyph, height: Household.plusStroke)
            Capsule()
                .fill(Color(at: .pureBlack))
                .frame(width: Household.plusStroke, height: Household.plusGlyph)
        }
        .frame(width: Household.plus, height: Household.plus)
        .accessibilityHidden(true)
    }

    private func tap() {
        guard isSelected else {
            onSelect()
            return
        }
        adds += 1
        onAdd()
    }
}

struct ProfileV3HouseholdPlaceholder: View {
    var body: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Household.shellSpacing) {
            ForEach(Array(ProfileV3Theme.Sizes.Household.shellHeights.enumerated()), id: \.offset) { _, height in
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .profileV3Card()
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Household card") {
    VStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3HouseholdCard(isSelected: true, onSelect: {}, onAdd: {})
        ProfileV3HouseholdPlaceholder()
    }
    .padding(.vertical, ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
