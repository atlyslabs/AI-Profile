import ATUIKit
import SwiftUI

struct ProfileV3PersonaProcessingCard: View {
    let traits: [String]
    var animates = true

    private typealias Persona = ProfileV3Theme.Sizes.Persona
    private typealias Layout = ProfileV3Theme.Sizes.PersonaProcessing

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3PersonaProcessingDial(traits: traits, animates: animates)
                .padding(.top, Persona.radarTop)
            Text(ProfileV3Strings.personaProcessing)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(ProfileV3Theme.personaCaptionGradient)
                .multilineTextAlignment(.center)
                .padding(.top, Layout.messageTop)
        }
        .padding(.bottom, Layout.bottom)
        .frame(maxWidth: .infinity)
    }
}

struct ProfileV3PersonaProcessingDial: View {
    let traits: [String]
    var animates = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date.now
    @State private var hasEntered = false
    @State private var waveTicks = 0

    private typealias Persona = ProfileV3Theme.Sizes.Persona
    private typealias Layout = ProfileV3Theme.Sizes.PersonaProcessing

    private var isStill: Bool { reduceMotion || !animates }

    var body: some View {
        TimelineView(ProfileV3AmbientSchedule(isPaused: isStill)) { context in
            let phase = isStill ? 0 : loopPhase(at: context.date)
            ZStack(alignment: .top) {
                ProfileV3PersonaLoader(rotation: .degrees(360 * phase))
                    .padding(.top, Layout.loaderTop)
                ForEach(Array(zip(ProfileV3PersonaProcessingSlot.all, traits).enumerated()), id: \.offset) { index, pair in
                    label(pair.1, slot: pair.0, index: index, phase: phase)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Persona.radarHeight, alignment: .top)
        .accessibilityHidden(true)
        .onAppear {
            start = .now
            hasEntered = true
        }
        .sensoryFeedback(
            .impact(flexibility: .soft, intensity: ProfileV3Theme.Motion.personaWaveTickIntensity),
            trigger: waveTicks
        )
        .task(id: isStill) {
            guard !isStill else { return }
            while !Task.isCancelled {
                let elapsed = Date.now.timeIntervalSince(start)
                let next = ProfileV3PersonaWave.nextPeak(after: elapsed)
                do {
                    try await Task.sleep(for: .seconds(next - elapsed))
                } catch {
                    return
                }
                waveTicks += 1
            }
        }
    }

    private func loopPhase(at date: Date) -> Double {
        let elapsed = date.timeIntervalSince(start) / ProfileV3Theme.Motion.personaProcessingLoop
        return elapsed - elapsed.rounded(.down)
    }

    private func label(_ name: String, slot: ProfileV3PersonaProcessingSlot, index: Int, phase: Double) -> some View {
        Text(name)
            .typoGraphy(.B2InterMedium12)
            .foregroundStyle(isStill ? ProfileV3PersonaWave.base.color : ProfileV3PersonaWave.color(at: phase, start: slot.waveStart))
            .multilineTextAlignment(slot.textAlignment)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: Layout.labelWidth, alignment: Alignment(horizontal: slot.alignment, vertical: .top))
            .offset(x: slot.centreOffset, y: slot.top)
            .opacity(hasEntered || isStill ? 1 : 0)
            .animation(entrance(index), value: hasEntered)
    }

    private func entrance(_ index: Int) -> Animation? {
        guard !isStill else { return nil }
        return ProfileV3Theme.Motion.personaLabelEntrance
            .delay(ProfileV3PersonaProcessingSlot.entranceDelay(index))
    }
}

struct ProfileV3PersonaProcessingSlot {
    let edge: CGFloat
    let top: CGFloat
    let alignment: HorizontalAlignment
    let waveStart: Double

    var textAlignment: TextAlignment {
        switch alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    var centreOffset: CGFloat {
        let half = ProfileV3Theme.Sizes.PersonaProcessing.labelWidth / 2
        switch alignment {
        case .leading: return edge + half
        case .trailing: return edge - half
        default: return edge
        }
    }

    static func entranceDelay(_ index: Int) -> Double {
        ProfileV3Theme.Motion.personaLabelDelay + ProfileV3Theme.Motion.personaLabelStagger * Double(index)
    }

    static let all = [
        ProfileV3PersonaProcessingSlot(edge: 0, top: 0, alignment: .center, waveStart: 0.63541),
        ProfileV3PersonaProcessingSlot(edge: 72, top: 23, alignment: .leading, waveStart: 0.7574),
        ProfileV3PersonaProcessingSlot(edge: 116, top: 97, alignment: .leading, waveStart: 0.85256),
        ProfileV3PersonaProcessingSlot(edge: 116, top: 185, alignment: .leading, waveStart: 0.94665),
        ProfileV3PersonaProcessingSlot(edge: 66, top: 253, alignment: .leading, waveStart: 0.03451),
        ProfileV3PersonaProcessingSlot(edge: 0, top: 275, alignment: .center, waveStart: 0.13882),
        ProfileV3PersonaProcessingSlot(edge: -69, top: 253, alignment: .trailing, waveStart: 0.24467),
        ProfileV3PersonaProcessingSlot(edge: -116, top: 185, alignment: .trailing, waveStart: 0.32144),
        ProfileV3PersonaProcessingSlot(edge: -116, top: 97, alignment: .trailing, waveStart: 0.42121),
        ProfileV3PersonaProcessingSlot(edge: -72, top: 23, alignment: .trailing, waveStart: 0.51474),
    ]
}

enum ProfileV3PersonaWave {
    struct RGB: Equatable {
        let red: Double
        let green: Double
        let blue: Double

        init(_ red: Double, _ green: Double, _ blue: Double) {
            self.red = red
            self.green = green
            self.blue = blue
        }

        var color: Color {
            Color(.sRGB, red: red / 255, green: green / 255, blue: blue / 255)
        }

        func mixed(with other: RGB, by amount: Double) -> RGB {
            RGB(
                red + (other.red - red) * amount,
                green + (other.green - green) * amount,
                blue + (other.blue - blue) * amount
            )
        }
    }

    static let base = RGB(17, 24, 39)
    static let keyframes: [(offset: Double, color: RGB)] = [
        (0, base),
        (0.0375, RGB(110, 61, 224)),
        (0.06625, RGB(214, 42, 156)),
        (0.085, RGB(245, 166, 209)),
        (0.10625, RGB(214, 42, 156)),
        (0.1575, base),
    ]

    static let peak = keyframes[3].offset

    static func color(at phase: Double, start: Double) -> Color {
        rgb(at: phase, start: start).color
    }

    static func nextPeak(after elapsed: TimeInterval) -> TimeInterval {
        let loop = ProfileV3Theme.Motion.personaProcessingLoop
        let times = ProfileV3PersonaProcessingSlot.all.enumerated().map { index, slot in
            var offset = slot.waveStart + peak
            offset -= offset.rounded(.down)
            let first = offset * loop
            let earliest = max(elapsed, ProfileV3PersonaProcessingSlot.entranceDelay(index))
            var time = first + max(((earliest - first) / loop).rounded(.up), 0) * loop
            if time <= elapsed { time += loop }
            return time
        }
        return times.min() ?? elapsed + loop
    }

    static func rgb(at phase: Double, start: Double) -> RGB {
        var offset = phase - start
        offset -= offset.rounded(.down)
        for (from, to) in zip(keyframes, keyframes.dropFirst()) where offset <= to.offset {
            guard offset >= from.offset else { break }
            return from.color.mixed(with: to.color, by: (offset - from.offset) / (to.offset - from.offset))
        }
        return base
    }
}

struct ProfileV3PersonaLoader: View {
    let rotation: Angle

    private typealias Layout = ProfileV3Theme.Sizes.PersonaProcessing

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(at: .pureWhite))
            Circle()
                .strokeBorder(ProfileV3Theme.personaLoaderRing, lineWidth: Layout.ring)
            knob
            arc
        }
        .frame(width: Layout.loader, height: Layout.loader)
        .overlay { innerShadow }
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(ProfileV3Theme.personaLoaderRim, lineWidth: Layout.rim)
        }
        .compositingGroup()
        .shadow(
            color: ProfileV3Theme.Palette.personaLoaderShadow.opacity(ProfileV3Theme.Opacity.personaLoaderShadow),
            radius: Layout.dropShadowRadius,
            y: Layout.dropShadowY
        )
        .compositingGroup()
        .opacity(ProfileV3Theme.Opacity.personaLoader)
    }

    private var knob: some View {
        ZStack {
            Circle()
                .fill(ProfileV3Theme.Palette.personaKnobShadow.opacity(ProfileV3Theme.Opacity.personaKnobShadow))
                .frame(width: Layout.knob - 2 * Layout.knobShadowInset, height: Layout.knob - 2 * Layout.knobShadowInset)
                .offset(y: Layout.knobShadowY)
                .blur(radius: Layout.knobShadowBlur)
                .blendMode(.multiply)
            Circle()
                .fill(ProfileV3Theme.personaKnobFill)
                .overlay {
                    Circle()
                        .stroke(ProfileV3Theme.personaKnobEdge, lineWidth: Layout.knobStroke)
                }
                .frame(width: Layout.knob, height: Layout.knob)
        }
    }

    private var arc: some View {
        Circle()
            .trim(from: Layout.arcTrimStart, to: 1)
            .stroke(ProfileV3Theme.personaArcGradient, style: StrokeStyle(lineWidth: Layout.arcLineWidth, lineCap: .round))
            .opacity(ProfileV3Theme.Opacity.personaArc)
            .frame(width: Layout.arc, height: Layout.arc)
            .rotationEffect(rotation)
            .offset(x: Layout.arcOffset, y: Layout.arcOffset)
    }

    private var innerShadow: some View {
        Circle()
            .fill(Color.black.opacity(ProfileV3Theme.Opacity.personaInnerShadow))
            .mask {
                ZStack {
                    Rectangle()
                        .padding(-Layout.loader / 2)
                    Circle()
                        .padding(Layout.innerShadowSpread)
                        .offset(y: Layout.innerShadowY)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .blur(radius: Layout.innerShadowBlur)
            }
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }
}

#if DEBUG
#Preview("Persona processing card") {
    ScrollView {
        ProfileV3PersonaProcessingCard(traits: ProfileV3PersonaFixtures.traits.map(\.name))
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Space.s50)
    }
}

#Preview("Persona processing loader") {
    ProfileV3PersonaLoader(rotation: .zero)
        .padding(ProfileV3Theme.Space.s40)
}
#endif
