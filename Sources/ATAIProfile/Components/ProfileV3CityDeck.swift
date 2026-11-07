import ATUIKit
import SwiftUI

struct ProfileV3CityDeck: View {
    let samples: [ProfileV3CitySample]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    private typealias Sizes = ProfileV3Theme.Sizes.City

    private var cycles: Bool { samples.count >= 3 && !reduceMotion }

    var body: some View {
        Group {
            if cycles {
                TimelineView(.animation) { context in
                    deck(elapsed: context.date.timeIntervalSince(start))
                }
            } else {
                deck(elapsed: 0)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Sizes.introDeckHeight, alignment: .top)
        .accessibilityHidden(true)
    }

    private func deck(elapsed: TimeInterval) -> some View {
        let step = Int(elapsed / ProfileV3Theme.Motion.cityDeckStepSeconds)
        let local = elapsed - Double(step) * ProfileV3Theme.Motion.cityDeckStepSeconds
        return ZStack {
            ForEach(Array(samples.enumerated()), id: \.element.id) { index, sample in
                let slot = ((index - step) % samples.count + samples.count) % samples.count
                let pose = ProfileV3CityDeckPose(slot: slot, local: cycles ? local : 0)
                ProfileV3CityDeckCard(sample: sample)
                    .rotationEffect(.degrees(pose.rotation))
                    .offset(pose.offset)
                    .opacity(pose.opacity)
                    .zIndex(pose.zIndex)
            }
        }
        .frame(width: Sizes.deckCard.width, height: Sizes.deckCard.height)
    }
}

struct ProfileV3CityDeckPose: Equatable {
    var rotation: Double = 0
    var offset: CGSize = .zero
    var opacity: Double = 0
    var zIndex: Double = 0

    init(slot: Int, local: TimeInterval) {
        typealias Motion = ProfileV3Theme.Motion
        typealias Sizes = ProfileV3Theme.Sizes.City
        let moveEnd = Motion.cityDeckHoldSeconds + Motion.cityDeckMoveSeconds
        let move = Self.progress(local - Motion.cityDeckHoldSeconds, over: Motion.cityDeckMoveSeconds)
        switch slot {
        case 0 where local < moveEnd:
            let eased = UnitCurve.easeIn.value(at: move)
            let fade = Self.progress(local - Motion.cityDeckFadeStartSeconds, over: moveEnd - Motion.cityDeckFadeStartSeconds)
            rotation = Sizes.deckDropTilt * eased
            offset = CGSize(width: Sizes.deckDrop.width * eased, height: Sizes.deckDrop.height * eased)
            opacity = 1 - UnitCurve.easeIn.value(at: fade)
            zIndex = 3
        case 0:
            let reveal = Self.progress(local - moveEnd, over: Motion.cityDeckRevealSeconds)
            rotation = Sizes.deckBackTilt
            opacity = ProfileV3Theme.Opacity.cityDeckBack * UnitCurve.easeOut.value(at: reveal)
        case 1:
            let eased = UnitCurve.easeInOut.value(at: move)
            rotation = Sizes.deckMiddleTilt * (1 - eased)
            opacity = ProfileV3Theme.Opacity.cityDeckMiddle + (1 - ProfileV3Theme.Opacity.cityDeckMiddle) * eased
            zIndex = 2
        case 2:
            let eased = UnitCurve.easeInOut.value(at: move)
            rotation = Sizes.deckBackTilt + (Sizes.deckMiddleTilt - Sizes.deckBackTilt) * eased
            opacity = ProfileV3Theme.Opacity.cityDeckBack
                + (ProfileV3Theme.Opacity.cityDeckMiddle - ProfileV3Theme.Opacity.cityDeckBack) * eased
            zIndex = 1
        default:
            break
        }
    }

    private static func progress(_ elapsed: TimeInterval, over duration: TimeInterval) -> Double {
        guard duration > 0 else { return 1 }
        return min(max(elapsed / duration, 0), 1)
    }
}

private struct ProfileV3CityDeckCard: View {
    let sample: ProfileV3CitySample

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Sizes.deckCardRadius, style: .continuous)
        ZStack(alignment: .topLeading) {
            ProfileV3Theme.Palette.cityDeckCard
            ProfileV3RemoteImage(url: sample.imageURL, placeholder: .clear)
                .frame(width: Sizes.deckCard.width, height: Sizes.deckCard.height)
            VStack(alignment: .leading, spacing: 0) {
                Text(sample.code)
                    .font(.Inter.get(size: Sizes.deckCodeSize, weight: .medium))
                    .tracking(Sizes.deckCodeTracking)
                Text(sample.name)
                    .typoGraphy(.H7InterMedium16)
                    .opacity(ProfileV3Theme.Opacity.cityWindowName)
                    .padding(.top, Sizes.deckNameTop)
                tag
                    .padding(.top, Sizes.deckTagTop)
            }
            .foregroundStyle(Color(at: .pureWhite))
            .lineLimit(1)
            .padding(Sizes.deckPadding)
            VStack(spacing: Sizes.deckPillSpacing) {
                ForEach(Array(sample.lines.prefix(2).enumerated()), id: \.offset) { index, text in
                    pill(text)
                        .rotationEffect(.degrees(index == 0 ? Sizes.deckPillTilt : Sizes.deckPillTiltSecond))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Sizes.deckPillsTop)
        }
        .frame(width: Sizes.deckCard.width, height: Sizes.deckCard.height)
        .clipShape(shape)
    }

    private var tag: some View {
        HStack(spacing: ProfileV3Theme.Space.s8) {
            if let iconURL = sample.purpose.iconURL {
                ProfileV3RemoteImage(url: iconURL, contentMode: .fit, placeholder: .clear, tint: Color(at: .pureWhite))
                    .frame(width: Sizes.deckTagIcon, height: Sizes.deckTagIcon)
            }
            Text(sample.purpose.label)
                .typoGraphy(.B2InterMedium12)
        }
        .padding(.horizontal, ProfileV3Theme.Space.s12)
        .frame(height: Sizes.deckTagHeight)
        .background(Capsule().fill(ProfileV3Theme.Palette.cityDeckTagFill))
        .modifier(ProfileV3CityDeckTagGlass())
        .shadow(color: ProfileV3Theme.Palette.cityDeckTagShadow, radius: Sizes.deckTagShadowRadius, y: Sizes.deckTagShadowY)
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .typoGraphy(.B1InterMedium14)
            .foregroundStyle(Color(at: .pureWhite))
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, Sizes.deckPillPadding)
            .frame(width: Sizes.deckPill.width, height: Sizes.deckPill.height)
            .background {
                Capsule()
                    .fill(ProfileV3Theme.Palette.cityDeckPill)
                    .background(.ultraThinMaterial, in: Capsule())
            }
    }
}

private struct ProfileV3CityDeckTagGlass: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *), ProfileV3FeatureFlags.isFloatingControlGlassEnabled {
            content.glassEffect(.regular, in: Capsule())
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(ProfileV3Theme.Palette.cityDeckTagBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
        }
    }
}

#if DEBUG
#Preview("City deck") {
    ProfileV3CityDeck(samples: ProfileV3CityProfileFixtures.samples)
        .padding(.vertical, ProfileV3Theme.Space.s50)
        .background(Color(at: .pureWhite))
}
#endif
