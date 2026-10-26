import ATUIKit
import SwiftUI

struct ProfileV3WorldPassCard: View {
    let pass: ProfileV3WorldPass
    var glowTrigger = 0
    var showsFlipTab = false
    var flipTabOpacity: Double = 1
    var animatesGlobe = true
    var globePose: ProfileV3GlobePose?

    var body: some View {
        ZStack {
            Color(at: .pureBlack)
            if ProfileV3FeatureFlags.isGlobeEnabled {
                ProfileV3CardGlobe(
                    isAnimating: animatesGlobe,
                    facingLongitude: ProfileV3Theme.Globe.cardLongitude,
                    appearance: ProfileV3Theme.Globe.cardAppearance,
                    pose: globePose
                )
                .frame(width: ProfileV3Theme.Sizes.worldPassGlobe, height: ProfileV3Theme.Sizes.worldPassGlobe)
                .overlay {
                    ProfileV3GlobeRim()
                        .frame(
                            width: ProfileV3Theme.Sizes.worldPassGlobeSphere,
                            height: ProfileV3Theme.Sizes.worldPassGlobeSphere
                        )
                }
                .background {
                    ProfileV3GlobeOrbits()
                        .frame(
                            width: ProfileV3Theme.Sizes.worldPassGlobeOrbits,
                            height: ProfileV3Theme.Sizes.worldPassGlobeOrbits
                        )
                }
                .offset(y: ProfileV3Theme.Sizes.worldPassGlobeOffsetY)
            }
            ProfileV3Theme.Palette.worldPassWash
            if pass.resolvedKYCGlowTone != .hidden {
                ProfileV3KYCGlow(
                    title: pass.kycTitle,
                    subtitle: pass.kycSubtitle,
                    tone: pass.resolvedKYCGlowTone,
                    trigger: glowTrigger
                )
            }
            VStack(spacing: 0) {
                ProfileV3WorldPassHeader(brand: pass.brand)
                    .padding(.top, ProfileV3Theme.Space.s20)
                Spacer()
                footer
                    .padding(.bottom, ProfileV3Theme.Space.s16)
            }
        }
        .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.worldPassHeight)
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius, style: .continuous))
        .overlay(alignment: .topLeading) {
            if showsFlipTab {
                ProfileV3FlipAffordance()
                    .opacity(flipTabOpacity)
                    .transition(.opacity)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: ProfileV3Theme.Space.s14) {
            Text(pass.holderName)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(Color(at: .pureWhite))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            if pass.memberNumber.nonEmpty != nil {
                Rectangle()
                    .fill(ProfileV3Theme.Palette.cardDivider)
                    .frame(
                        width: ProfileV3Theme.Sizes.worldPassDividerWidth,
                        height: ProfileV3Theme.Stroke.hairline
                    )
            }
            ProfileV3PassNumber(number: pass.memberNumber, maxWidth: ProfileV3Theme.Sizes.worldPassNumberMaxWidth)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.worldPassContentInset)
    }
}

struct ProfileV3WorldPassHeader: View {
    let brand: String?

    var body: some View {
        if let brand = brand?.nonEmpty {
            HStack(spacing: ProfileV3Theme.Space.s4) {
                ProfileV3Vector.worldPassPlus.image
                    .profileV3Icon(ProfileV3Theme.Icon.sm)
                    .rotationEffect(.degrees(ProfileV3Theme.Rotation.quarter))
                Text(brand)
                    .font(Font.Inter.get(size: ProfileV3Theme.Typography.worldPassHeaderSize, weight: .regular))
                    .tracking(ProfileV3Theme.Typography.worldPassHeaderTracking)
            }
            .foregroundStyle(ProfileV3Theme.worldPassTitleGradient)
            .opacity(ProfileV3Theme.Opacity.worldPassSubtitle)
        }
    }
}

#if DEBUG
#Preview("World Pass card") {
    ProfileV3WorldPassCard(pass: ProfileV3Fixtures.worldPass)
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
