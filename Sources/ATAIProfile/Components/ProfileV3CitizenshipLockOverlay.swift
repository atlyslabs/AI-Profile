import ATUIKit
import SwiftUI

struct ProfileV3CitizenshipLockOverlay: View {
    let country: ProfileV3Country
    let trigger: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var cover: ProfileV3PassportCover { country == .india ? .india : .generic }

    var body: some View {
        let rise = reduceMotion ? 0 : ProfileV3Theme.Sizes.CitizenshipLock.rise
        ZStack(alignment: .bottom) {
            ProfileV3Theme.citizenshipLockFade
                .frame(height: ProfileV3Theme.Sizes.CitizenshipLock.fadeHeight)
            VStack(spacing: 0) {
                flag
                Text(ProfileV3Strings.citizenshipFromPassport)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(ProfileV3Theme.Palette.citizenshipLockCopy)
                    .multilineTextAlignment(.center)
                    .frame(width: ProfileV3Theme.Sizes.CitizenshipLock.copyWidth)
                    .padding(.top, ProfileV3Theme.Sizes.CitizenshipLock.flagToCopy)
                ProfileV3RemoteImage(url: cover.art.url, contentMode: .fill, placeholder: .clear)
                    .frame(width: cover.width, height: cover.height)
                    .clipShape(RoundedRectangle(cornerRadius: cover.cornerRadius, style: .continuous))
                    .padding(.top, cover.gap)
            }
            .offset(y: cover.overhang)
            ProfileV3Theme.clearToWhiteFade
                .frame(height: ProfileV3Theme.Sizes.CitizenshipLock.bottomFadeHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .keyframeAnimator(
            initialValue: ProfileV3CitizenshipLockMotion(opacity: 0, offset: rise),
            trigger: trigger
        ) { content, value in
            content
                .compositingGroup()
                .opacity(value.opacity)
                .offset(y: value.offset)
        } keyframes: { _ in
            KeyframeTrack(\.opacity) {
                LinearKeyframe(
                    1,
                    duration: ProfileV3Theme.Motion.citizenshipLockFadeInSeconds,
                    timingCurve: ProfileV3Theme.Motion.citizenshipLockEnter
                )
                LinearKeyframe(1, duration: ProfileV3Theme.Motion.citizenshipLockVisibleSeconds)
                LinearKeyframe(
                    0,
                    duration: ProfileV3Theme.Motion.citizenshipLockFadeOutSeconds,
                    timingCurve: ProfileV3Theme.Motion.citizenshipLockExit
                )
            }
            KeyframeTrack(\.offset) {
                LinearKeyframe(
                    0,
                    duration: ProfileV3Theme.Motion.citizenshipLockRiseSeconds,
                    timingCurve: ProfileV3Theme.Motion.citizenshipLockEnter
                )
                LinearKeyframe(0, duration: ProfileV3Theme.Motion.citizenshipLockHoldSeconds)
                LinearKeyframe(
                    rise,
                    duration: ProfileV3Theme.Motion.citizenshipLockRiseSeconds,
                    timingCurve: ProfileV3Theme.Motion.citizenshipLockExit
                )
            }
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var flag: some View {
        ProfileV3CountryFlag(isoCode: country.code, size: ProfileV3Theme.Sizes.CitizenshipLock.flag)
    }
}

private struct ProfileV3CitizenshipLockMotion {
    var opacity: Double
    var offset: CGFloat
}

private struct ProfileV3PassportCover {
    let art: ProfileV3PlaceholderArt
    let width: CGFloat
    let height: CGFloat
    let gap: CGFloat
    let overhang: CGFloat
    let cornerRadius: CGFloat

    static let india = Self(
        art: .passportCoverIndia,
        width: ProfileV3Theme.Sizes.CitizenshipLock.indiaCoverWidth,
        height: ProfileV3Theme.Sizes.CitizenshipLock.indiaCoverHeight,
        gap: ProfileV3Theme.Sizes.CitizenshipLock.indiaCoverGap,
        overhang: ProfileV3Theme.Sizes.CitizenshipLock.indiaCoverOverhang,
        cornerRadius: ProfileV3Theme.Sizes.CitizenshipLock.indiaCoverRadius
    )

    static let generic = Self(
        art: .passportCoverGeneric,
        width: ProfileV3Theme.Sizes.CitizenshipLock.genericCoverWidth,
        height: ProfileV3Theme.Sizes.CitizenshipLock.genericCoverHeight,
        gap: ProfileV3Theme.Sizes.CitizenshipLock.genericCoverGap,
        overhang: ProfileV3Theme.Sizes.CitizenshipLock.genericCoverOverhang,
        cornerRadius: 0
    )
}

#if DEBUG
private struct ProfileV3CitizenshipLockPreview: View {
    @State private var trigger = 0

    var body: some View {
        ZStack {
            Color(at: .pureWhite)
            Button("Tap locked citizenship") { trigger += 1 }
        }
        .overlay { ProfileV3CitizenshipLockOverlay(country: .india, trigger: trigger) }
    }
}

#Preview("Citizenship lock") {
    ProfileV3CitizenshipLockPreview()
}
#endif
