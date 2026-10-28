import ATUIKit
import SwiftUI

struct ProfileV3CustomRulesSection: View {
    @ObservedObject var model: ProfileV3CustomRulesModel

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules

    var body: some View {
        if !model.rules.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ProfileV3SectionHeader(title: ProfileV3Strings.customRulesTitle, status: .complete)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Sizes.cardSpacing) {
                        ForEach(model.rules) { rule in
                            ProfileV3CustomRuleCard(text: rule.text) { model.startEditing(rule) }
                        }
                    }
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                }
                .padding(.horizontal, -ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sizes.cardsTop)
            }
        }
    }
}

struct ProfileV3CustomRuleCard: View {
    let text: String
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Sizes.cardRadius, style: .continuous)
                    .fill(ProfileV3Theme.ruleNoteGradient)
                RoundedRectangle(cornerRadius: Sizes.cardBevelRadius, style: .continuous)
                    .fill(ProfileV3Theme.ruleNoteBevel)
                    .padding(Sizes.cardBevelInset)
                Text(text)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .neutralGrey800))
                    .multilineTextAlignment(.leading)
                    .lineLimit(Sizes.cardTextLines)
                    .frame(width: Sizes.cardTextWidth, alignment: .leading)
                    .padding(.leading, Sizes.cardTextLeading)
                    .padding(.top, Sizes.cardTextTop)
            }
            .frame(width: Sizes.card.width, height: Sizes.card.height)
            .contentShape(RoundedRectangle(cornerRadius: Sizes.cardRadius, style: .continuous))
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(text)
        .accessibilityHint(ProfileV3Strings.editRuleTitle)
    }
}

struct ProfileV3CustomRuleNote<Content: View>: View {
    enum Style {
        case front
        case back
    }

    var style = Style.front
    @ViewBuilder let content: Content

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Sizes.noteRadius, style: .continuous)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            shape.fill(style == .front ? ProfileV3Theme.ruleNoteGradient : ProfileV3Theme.ruleNoteBackGradient)
            shape
                .fill(ProfileV3Theme.ruleNoteBevel)
                .padding(Sizes.noteBevelInset)
            ProfileV3CustomRuleArt.watermark.image
                .resizable()
                .frame(width: Sizes.watermark.width, height: Sizes.watermark.height)
                .position(
                    x: Sizes.note.width / 2 + Sizes.watermarkCentreOffset.width,
                    y: Sizes.note.height / 2 + Sizes.watermarkCentreOffset.height
                )
                .accessibilityHidden(true)
            Text(ProfileV3Strings.ruleNoteLabel)
                .font(.system(size: Sizes.noteLabelSize, weight: .bold, design: .monospaced))
                .tracking(Sizes.noteLabelTracking)
                .textCase(.uppercase)
                .foregroundStyle(ProfileV3Theme.Palette.ruleNoteLabel)
                .padding(.leading, Sizes.noteLabelLeading)
                .padding(.top, Sizes.noteLabelTop)
                .accessibilityHidden(true)
            content
                .frame(width: Sizes.noteTextWidth, alignment: .topLeading)
                .frame(maxHeight: Sizes.note.height - Sizes.noteTextTop - Sizes.noteTextBottom, alignment: .topLeading)
                .padding(.leading, Sizes.noteTextLeading)
                .padding(.top, Sizes.noteTextTop)
        }
        .frame(width: Sizes.note.width, height: Sizes.note.height)
        .clipShape(shape)
    }
}

struct ProfileV3CustomRuleEditorHost: View {
    @ObservedObject var model: ProfileV3CustomRulesModel

    var body: some View {
        ZStack {
            if let editor = model.editor {
                ProfileV3CustomRuleEditor(model: model, editor: editor)
                    .transition(.opacity)
            }
        }
        .animation(ProfileV3Theme.Motion.customRuleEditor, value: model.editor)
    }
}

private struct ProfileV3CustomRuleEditor: View {
    @ObservedObject var model: ProfileV3CustomRulesModel
    let editor: ProfileV3CustomRulesModel.Editor

    @FocusState private var isFocused: Bool

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules

    var body: some View {
        VStack(spacing: 0) {
            header
            notes
                .padding(.top, Sizes.noteTop - ProfileV3Theme.Sizes.circleButton)
            bottom
                .padding(.top, Sizes.pillTop)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Color(at: .pureWhite)
                .opacity(ProfileV3Theme.Opacity.ruleBackdrop)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
        }
        .animation(ProfileV3Theme.Motion.saveState, value: model.phase)
        .animation(ProfileV3Theme.Motion.saveState, value: model.canSave)
        .animation(ProfileV3Theme.Motion.saveState, value: model.dropped)
        .sensoryFeedback(.success, trigger: model.dropped) { _, dropped in dropped != nil }
        .sensoryFeedback(.success, trigger: model.phase) { _, phase in phase == .saved }
        .sensoryFeedback(.error, trigger: model.errorMessage) { _, message in message != nil }
        .onAppear { isFocused = true }
    }

    private var header: some View {
        ZStack {
            HStack {
                ProfileV3CircleIconButton.back(action: model.close)
                Spacer(minLength: 0)
            }
            Text(editor.isAdding ? ProfileV3Strings.addRuleTitle : ProfileV3Strings.editRuleTitle)
                .typoGraphy(.H5InterSemibold20)
                .foregroundStyle(Color(at: .pureBlack))
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
    }

    private var notes: some View {
        ZStack {
            ProfileV3CustomRuleNote(style: .back) { EmptyView() }
                .opacity(ProfileV3Theme.Opacity.ruleBackNote)
                .rotationEffect(.degrees(Sizes.backTilt))
                .accessibilityHidden(true)
            ProfileV3CustomRuleNote {
                TextField("", text: $model.draft, axis: .vertical)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(ProfileV3Theme.Palette.ruleNoteText)
                    .tint(ProfileV3Theme.Palette.ruleNoteText)
                    .focused($isFocused)
                    .disabled(model.phase != .editing)
                    .accessibilityLabel(ProfileV3Strings.ruleNoteLabel)
            }
            if let dropped = model.dropped {
                ProfileV3CustomRuleDrop(text: dropped.text)
                    .id(dropped.id)
            }
        }
        .overlay(alignment: .topTrailing) {
            if !editor.isAdding {
                trash
                    .offset(x: Sizes.trash / 2 - Sizes.trashFromCorner, y: -Sizes.trash / 2)
            }
        }
    }

    private var trash: some View {
        Button(action: model.delete) {
            ATIcon.SwiftUIImage.delete
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(ProfileV3Theme.Palette.ruleTrash)
                .frame(width: Sizes.trash, height: Sizes.trash)
                .background(Circle().fill(Color(at: .pureWhite)))
                .overlay(Circle().strokeBorder(ProfileV3Theme.Palette.ruleTrashBorder, lineWidth: ProfileV3Theme.Stroke.thin))
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .disabled(model.phase != .editing)
        .accessibilityLabel(ProfileV3Strings.deleteRule)
    }

    @ViewBuilder
    private var bottom: some View {
        VStack(spacing: ProfileV3Theme.Space.s12) {
            if let error = model.errorMessage {
                Text(error)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.Palette.error)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
            if editor.isAdding {
                if model.showsSavedToast {
                    ProfileV3CustomRulePill(title: ProfileV3Strings.customRuleSaved)
                        .transition(.opacity)
                        .accessibilityAddTraits(.updatesFrequently)
                } else if model.canSave || model.phase == .saving {
                    Button(action: model.save) {
                        ProfileV3CustomRulePill(title: ProfileV3Strings.saveRule, isLoading: model.phase == .saving)
                    }
                    .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
                    .disabled(model.phase != .editing)
                    .transition(.opacity)
                }
            } else if model.canSave || model.phase != .editing {
                ProfileV3SaveButton(
                    phase: savePhase,
                    title: ProfileV3Strings.saveChanges,
                    savedTitle: ProfileV3Strings.customRuleSaved,
                    action: model.save
                )
                .transition(.opacity)
            }
        }
        .frame(minHeight: Sizes.pillHeight, alignment: .top)
    }

    private var savePhase: ProfileV3SavePhase {
        switch model.phase {
        case .editing: return .idle
        case .saving: return .saving
        case .saved: return .saved
        }
    }
}

private struct ProfileV3CustomRulePill: View {
    let title: String
    var isLoading = false

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(Color(at: .pureWhite))
            } else {
                Text(title)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureWhite))
            }
        }
        .padding(.horizontal, Sizes.pillHorizontal)
        .frame(minWidth: Sizes.pillMinWidth)
        .frame(height: Sizes.pillHeight)
        .background(Capsule().fill(ProfileV3Theme.Palette.rulePill))
        .shadow(
            color: Color.black.opacity(ProfileV3Theme.Opacity.rulePillShadow),
            radius: Sizes.pillShadowRadius,
            y: Sizes.pillShadowY
        )
        .contentShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

private struct ProfileV3CustomRuleDropFrame {
    var glow: Double = 0
    var y: CGFloat = 0
    var angle: Double = 0
    var opacity: Double = 1
}

private struct ProfileV3CustomRuleDrop: View {
    let text: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules
    private typealias Motion = ProfileV3Theme.Motion

    var body: some View {
        if !reduceMotion {
            ProfileV3CustomRuleNote {
                Text(text)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(ProfileV3Theme.Palette.ruleNoteText)
            }
            .keyframeAnimator(initialValue: ProfileV3CustomRuleDropFrame(), repeating: false) { content, frame in
                content
                    .overlay {
                        ProfileV3Theme.ruleGlow
                            .opacity(frame.glow)
                            .clipShape(RoundedRectangle(cornerRadius: Sizes.noteRadius, style: .continuous))
                    }
                    .rotationEffect(.degrees(frame.angle))
                    .offset(y: frame.y)
                    .opacity(frame.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.glow) {
                    LinearKeyframe(ProfileV3Theme.Opacity.ruleGlowPeak, duration: Motion.customRuleGlowIn, timingCurve: .easeInOut)
                    LinearKeyframe(0, duration: Motion.customRuleGlowOut, timingCurve: .easeInOut)
                }
                KeyframeTrack(\.y) {
                    LinearKeyframe(0, duration: Motion.customRuleHold)
                    LinearKeyframe(Sizes.dropLift, duration: Motion.customRuleLift, timingCurve: .easeOut)
                    LinearKeyframe(Sizes.dropMid, duration: Motion.customRuleFallStart, timingCurve: .easeIn)
                    LinearKeyframe(Sizes.dropFall, duration: Motion.customRuleFallEnd, timingCurve: .easeIn)
                }
                KeyframeTrack(\.angle) {
                    LinearKeyframe(0, duration: Motion.customRuleHold)
                    LinearKeyframe(Sizes.dropLeanBack, duration: Motion.customRuleLift, timingCurve: .easeOut)
                    LinearKeyframe(Sizes.dropTiltMid, duration: Motion.customRuleFallStart, timingCurve: .easeInOut)
                    LinearKeyframe(Sizes.dropTilt, duration: Motion.customRuleFallEnd, timingCurve: .easeIn)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(1, duration: Motion.customRuleHold + Motion.customRuleLift + Motion.customRuleFallStart)
                    LinearKeyframe(0, duration: Motion.customRuleFallEnd, timingCurve: .easeIn)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

struct ProfileV3CustomRuleButton: View {
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules

    var body: some View {
        Button(action: action) {
            HStack(spacing: Sizes.customPillGap) {
                ATIcon.SwiftUIImage.add
                    .profileV3Icon(Sizes.customPillIcon)
                Text(ProfileV3Strings.customRuleButton)
                    .typoGraphy(.B1InterSemibold14)
            }
            .foregroundStyle(Color(at: .pureBlack))
            .padding(.leading, Sizes.customPillLeading)
            .padding(.trailing, Sizes.customPillTrailing)
            .frame(height: Sizes.customPillHeight)
            .profileV3CapsuleChrome()
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .accessibilityLabel(ProfileV3Strings.addRuleTitle)
    }
}

#if DEBUG
#Preview("Custom rule cards") {
    ProfileV3CustomRulesSection(model: .preview)
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}

#Preview("Custom rule note") {
    ZStack {
        ProfileV3CustomRuleNote(style: .back) { EmptyView() }
            .opacity(ProfileV3Theme.Opacity.ruleBackNote)
            .rotationEffect(.degrees(ProfileV3Theme.Sizes.CustomRules.backTilt))
        ProfileV3CustomRuleNote {
            Text("Pick a veg restaurant every time Aakanksha is on the trip. Make sure the veg food doesn’t have egg")
                .typoGraphy(.H7InterMedium16)
        }
    }
    .padding(ProfileV3Theme.Space.s40)
    .background(Color(at: .pureWhite))
}

extension ProfileV3CustomRulesModel {
    static var preview: ProfileV3CustomRulesModel {
        let model = ProfileV3CustomRulesModel(agentID: "food", profileID: nil, repository: ProfileV3MockRepository(delay: .zero))
        model.startAdding()
        model.draft = "Pick a veg restaurant every time. Aakanksha is on the trip. Make sure the veg food doesn’t have egg"
        model.save()
        return model
    }
}
#endif
