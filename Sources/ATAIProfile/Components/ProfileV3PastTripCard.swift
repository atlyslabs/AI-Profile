import ATUIKit
import SwiftUI

struct ProfileV3PastTripCard: View {
    let trip: ProfileV3PastTrip
    let reveals: Bool
    let sheenDelay: Double?
    var onRevealEnd: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var photoBlur: CGFloat
    @State private var yearBlur: CGFloat
    @State private var glowOpacity: Double = 0
    @State private var sheens = 0
    @State private var nameHeights = NameHeights()

    private struct NameHeights: Equatable {
        var name: CGFloat = 0
        var oneLine: CGFloat = 0

        var extra: CGFloat { max(0, name - oneLine) }
    }

    init(
        trip: ProfileV3PastTrip,
        reveals: Bool = false,
        sheenDelay: Double? = nil,
        onRevealEnd: (() -> Void)? = nil
    ) {
        self.trip = trip
        self.reveals = reveals
        self.sheenDelay = sheenDelay
        self.onRevealEnd = onRevealEnd
        _photoBlur = State(initialValue: reveals ? ProfileV3Theme.Sizes.PastTrips.revealPhotoBlur : 0)
        _yearBlur = State(initialValue: reveals ? ProfileV3Theme.Sizes.PastTrips.revealYearBlur : 0)
    }

    private typealias Sizes = ProfileV3Theme.Sizes.PastTrips

    private var photoSize: CGSize {
        CGSize(width: Sizes.cardWidth - 2 * Sizes.photoInset, height: Sizes.cardHeight - 2 * Sizes.photoInset)
    }

    private var photoShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Sizes.photoRadius, style: .continuous)
    }

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: Sizes.cardRadius, style: .continuous)
                .fill(ProfileV3Theme.tripBezelGradient)
            photo
                .padding(.top, Sizes.photoInset)
            year
            details
        }
        .frame(width: Sizes.cardWidth, height: Sizes.cardHeight)
        .background { glow }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .task(id: reveals) { await play() }
    }

    private var accessibilityLabel: String {
        guard let date = trip.date, let month = trip.monthName else { return trip.countryName }
        return ProfileV3Strings.pastTripLabel(country: trip.countryName, month: month, year: date.year)
    }

    private var photo: some View {
        ZStack(alignment: .bottom) {
            ProfileV3RemoteImage(
                url: trip.displayImageURL,
                contentMode: .fill,
                placeholder: ProfileV3Theme.Palette.tripPhotoPlaceholder
            )
                .frame(width: photoSize.width, height: photoSize.height)
                .blur(radius: photoBlur, opaque: true)
            ProfileV3PastTripSheen(trigger: sheens)
            photoShape
                .strokeBorder(
                    Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.tripPhotoStroke),
                    lineWidth: ProfileV3Theme.Stroke.hairline
                )
            ProfileV3Theme.tripScrimGradient
                .frame(height: Sizes.scrimHeight)
        }
        .frame(width: photoSize.width, height: photoSize.height)
        .clipShape(photoShape)
    }

    private var year: some View {
        Text(verbatim: trip.date.map { String($0.year) } ?? " ")
            .font(Font.Inter.get(size: Sizes.yearSize, weight: .semibold))
            .tracking(Sizes.yearTracking)
            .foregroundStyle(ProfileV3Theme.tripYearGradient)
            .lineLimit(1)
            .fixedSize()
            .blur(radius: yearBlur)
            .padding(.top, Sizes.yearTop)
            .accessibilityHidden(true)
    }

    private var details: some View {
        VStack(spacing: 0) {
            flag
            Text(trip.countryName)
                .typoGraphy(.H4DentonMedium24)
                .foregroundStyle(Color(at: .pureWhite))
                .multilineTextAlignment(.center)
                .lineLimit(Sizes.nameLines)
                .minimumScaleFactor(ProfileV3Theme.Typography.tripNameMinScale)
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { nameHeights.name = $0 }
                .background {
                    Text(verbatim: " ")
                        .typoGraphy(.H4DentonMedium24)
                        .fixedSize()
                        .hidden()
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { nameHeights.oneLine = $0 }
                }
                .padding(.top, Sizes.nameTop)
            if let month = trip.monthName {
                Text(month)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.tripMonth))
                    .padding(.top, Sizes.monthTop)
            }
        }
        .padding(.top, Sizes.flagTop)
        .padding(.horizontal, ProfileV3Theme.Space.s20)
        .offset(y: -nameHeights.extra)
    }

    @ViewBuilder
    private var flag: some View {
        if let country = ATCountry(isoCode: trip.countryCode) {
            ATCountryFlagView(country: country)
                .frame(width: Sizes.flag, height: Sizes.flag)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color(at: .neutralGrey600))
                .frame(width: Sizes.flag, height: Sizes.flag)
        }
    }

    private var glow: some View {
        Circle()
            .fill(ProfileV3Theme.accessGlowGradient)
            .opacity(ProfileV3Theme.Opacity.accessGlowFill)
            .frame(width: Sizes.glow, height: Sizes.glow)
            .blur(radius: Sizes.glowBlur)
            .offset(y: Sizes.glowOffsetY)
            .opacity(glowOpacity)
            .allowsHitTesting(false)
    }

    private func play() async {
        if let sheenDelay, !reduceMotion {
            try? await Task.sleep(for: .seconds(sheenDelay))
            guard !Task.isCancelled else { return }
            sheens += 1
        }
        guard reveals else { return }
        guard !reduceMotion else {
            photoBlur = 0
            yearBlur = 0
            onRevealEnd?()
            return
        }
        withAnimation(ProfileV3Theme.Motion.pastTripsGlowIn) { glowOpacity = 1 }
        sheens += 1
        try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.pastTripsGlowInSeconds))
        withAnimation(ProfileV3Theme.Motion.pastTripsReveal) {
            photoBlur = 0
            yearBlur = 0
            glowOpacity = ProfileV3Theme.Opacity.tripGlowSettled
        }
        try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.pastTripsRevealSeconds))
        withAnimation(ProfileV3Theme.Motion.pastTripsGlowOut) { glowOpacity = 0 }
        try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.pastTripsGlowOutSeconds))
        onRevealEnd?()
    }
}

private struct ProfileV3PastTripSheen: View {
    let trigger: Int

    private typealias Sizes = ProfileV3Theme.Sizes.PastTrips

    var body: some View {
        ZStack {
            shape
                .strokeBorder(ProfileV3Theme.tripSheenOuter, lineWidth: Sizes.sheenOuterWidth)
                .blur(radius: Sizes.sheenOuterBlur)
            shape
                .strokeBorder(ProfileV3Theme.tripSheenInner, lineWidth: Sizes.sheenInnerWidth)
                .blur(radius: Sizes.sheenInnerBlur)
        }
        .blendMode(.screen)
        .keyframeAnimator(initialValue: ProfileV3PastTripSheenFrame(), trigger: trigger) { content, frame in
            content
                .offset(x: frame.x)
                .opacity(frame.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.x) {
                MoveKeyframe(-Sizes.sheenTravel)
                LinearKeyframe(Sizes.sheenTravel, duration: ProfileV3Theme.Motion.pastTripsSheenSeconds)
            }
            KeyframeTrack(\.opacity) {
                MoveKeyframe(0)
                LinearKeyframe(
                    ProfileV3Theme.Opacity.tripSheen,
                    duration: ProfileV3Theme.Motion.pastTripsSheenSeconds / 2
                )
                LinearKeyframe(0, duration: ProfileV3Theme.Motion.pastTripsSheenSeconds / 2)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Sizes.photoRadius, style: .continuous)
    }
}

private struct ProfileV3PastTripSheenFrame {
    var x: CGFloat = -ProfileV3Theme.Sizes.PastTrips.sheenTravel
    var opacity: Double = 0
}

#if DEBUG
#Preview("Past trip card") {
    VStack(spacing: ProfileV3Theme.Sizes.PastTrips.cardSpacing) {
        ForEach(ProfileV3PastTripsFixtures.trips) { trip in
            ProfileV3PastTripCard(trip: trip)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ProfileV3Theme.Palette.pastTripsBackground)
}
#endif
