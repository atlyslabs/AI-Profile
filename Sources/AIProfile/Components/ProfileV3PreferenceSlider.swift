import ATUIKit
import SwiftUI

struct ProfileV3PreferenceSlider: View {
    let field: ProfileV3SliderField
    var label: String = ProfileV3Strings.preferenceSlider
    var onPreview: ((Double?) -> Void)?
    let onChange: (Double) -> Void

    @GestureState private var dragValue: Double?

    private var isDisabled: Bool { field.optOut?.isOn == true }

    private var displayField: ProfileV3SliderField { field.previewing(dragValue) }

    var body: some View {
        VStack(spacing: spacing) {
            track
                .compositingGroup()
                .opacity(isDisabled ? ProfileV3Theme.Opacity.sliderDisabled : 1)
            switch field.style {
            case .ruler:
                ProfileV3SliderRuler()
            case .labels(let labels):
                labelsRow(labels)
            }
        }
        .disabled(isDisabled)
        .animation(ProfileV3Theme.Motion.selection, value: isDisabled)
        .onChange(of: dragValue) { _, value in
            if value == nil { onPreview?(nil) }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: dragValue) { old, new in
            guard field.step >= 1, let new else { return false }
            return new != (old ?? field.value)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(displayField.readout?.value ?? sliderValue)
        .accessibilityAdjustableAction { direction in
            guard !isDisabled else { return }
            switch direction {
            case .increment:
                onChange(min(field.range.upperBound, field.value + field.step))
            case .decrement:
                onChange(max(field.range.lowerBound, field.value - field.step))
            default:
                break
            }
        }
    }

    private var sliderValue: String {
        "\(Int(displayField.value.rounded()))"
    }

    private var spacing: CGFloat {
        switch field.style {
        case .ruler: return ProfileV3Theme.Sizes.sliderRulerSpacing
        case .labels: return ProfileV3Theme.Space.s14
        }
    }

    private var track: some View {
        GeometryReader { proxy in
            let knob = ProfileV3Theme.Sizes.sliderKnob
            let usable = max(proxy.size.width - knob, 1)
            let knobX = knob / 2 + usable * displayField.fraction
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(ProfileV3Theme.Palette.sliderTrack)
                    .frame(height: ProfileV3Theme.Sizes.sliderTrackHeight)
                Capsule()
                    .fill(ProfileV3Theme.Palette.sliderFill)
                    .frame(width: knobX, height: ProfileV3Theme.Sizes.sliderTrackHeight)
                ProfileV3SliderKnob()
                    .position(x: knobX, y: proxy.size.height / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragValue) { value, state, _ in
                        let next = field.value(atFraction: (value.location.x - knob / 2) / usable)
                        if next != (state ?? field.value) {
                            state = next
                        }
                    }
                    .onChanged { value in
                        onPreview?(field.value(atFraction: (value.location.x - knob / 2) / usable))
                    }
                    .onEnded { value in
                        onPreview?(nil)
                        let next = field.value(atFraction: (value.location.x - knob / 2) / usable)
                        if next != field.value {
                            onChange(next)
                        }
                    }
            )
        }
        .frame(height: ProfileV3Theme.Sizes.sliderKnob)
    }

    private func labelsRow(_ labels: [String]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                if index > 0 {
                    Spacer(minLength: 0)
                }
                Text(label)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(ProfileV3Theme.Palette.secondaryText)
            }
        }
    }
}

private struct ProfileV3SliderKnob: View {
    var body: some View {
        Circle()
            .fill(ProfileV3Theme.sliderKnobRimGradient)
            .overlay {
                Circle()
                    .fill(
                        ProfileV3Theme.sliderKnobFaceGradient.shadow(
                            .inner(
                                color: ProfileV3Theme.Palette.sliderKnobShadow,
                                radius: ProfileV3Theme.Shadow.sliderKnobRadius,
                                y: ProfileV3Theme.Shadow.sliderKnobY
                            )
                        )
                    )
                    .padding(ProfileV3Theme.Sizes.sliderKnobRim)
            }
            .frame(width: ProfileV3Theme.Sizes.sliderKnob, height: ProfileV3Theme.Sizes.sliderKnob)
    }
}

#if DEBUG
private struct ProfileV3PreferenceSliderPreview: View {
    @State private var hours = ProfileV3SliderField(value: 10, range: 1...18, format: .unit("hrs max"))
    @State private var pacing = ProfileV3SliderField(
        value: 1, range: 0...2, style: .labels(["Relaxed", "Balanced", "Packed"])
    )

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s32) {
            ProfileV3PreferenceSlider(field: hours) { hours.value = $0 }
            ProfileV3PreferenceSlider(field: pacing) { pacing.value = $0 }
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
    }
}

#Preview("Preference sliders") {
    ProfileV3PreferenceSliderPreview()
}
#endif
