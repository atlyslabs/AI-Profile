import ATUIKit
import SwiftUI

struct ProfileV3CustomRulesSection: View {
    @ObservedObject var model: ProfileV3CustomRulesModel
    var onReveal: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules
    private static let rowStartID = "customRules.rowStart"

    var body: some View {
        if !model.rules.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ProfileV3SectionHeader(title: ProfileV3Strings.customRulesTitle, status: .complete)
                ScrollViewReader { row in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Sizes.cardSpacing) {
                            ForEach(model.rules) { rule in
                                ProfileV3CustomRuleCard(text: rule.text) { model.startEditing(rule) }
                            }
                        }
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .id(Self.rowStartID)
                    }
                    .onChange(of: model.revealedRuleID) {
                        withAnimation(reduceMotion ? nil : ProfileV3Theme.Motion.customRuleReveal) {
                            row.scrollTo(Self.rowStartID, anchor: .leading)
                            onReveal()
                        }
                    }
                }
                .trackScroll(.customRulesRail)
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
                .padding(.trailing, Sizes.watermarkInset.width)
                .padding(.bottom, Sizes.watermarkInset.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
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
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, Sizes.noteTextLeading)
                .padding(.top, Sizes.noteTextTop)
                .padding(.bottom, Sizes.noteTextBottom)
        }
        .frame(width: Sizes.note.width)
        .frame(minHeight: Sizes.noteMinHeight, idealHeight: Sizes.note.height, maxHeight: Sizes.note.height)
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
        ProfileV3CustomRuleEditorLayout {
            header
            notes
            bottom
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(at: .pureWhite)
                .opacity(ProfileV3Theme.Opacity.ruleBackdrop)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
        }
        .animation(ProfileV3Theme.Motion.saveState, value: model.phase)
        .animation(ProfileV3Theme.Motion.saveState, value: model.canSave)
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
                if model.phase == .saved {
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

struct ProfileV3CustomRuleEditorFit {
    let noteGap: CGFloat
    let noteHeight: CGFloat
    let pillGap: CGFloat

    init(height: CGFloat, header: CGFloat, bottom: CGFloat) {
        typealias Sizes = ProfileV3Theme.Sizes.CustomRules
        var noteGap = Sizes.noteTop - ProfileV3Theme.Sizes.circleButton
        var noteHeight = Sizes.note.height
        var pillGap = Sizes.pillTop
        var overflow = header + noteGap + noteHeight + pillGap + bottom + Sizes.pillMinBottom - height
        overflow = Self.squeeze(&pillGap, to: Sizes.pillMinTop, by: overflow)
        overflow = Self.squeeze(&noteGap, to: Sizes.noteMinTop, by: overflow)
        Self.squeeze(&noteHeight, to: Sizes.noteMinHeight, by: overflow)
        self.noteGap = noteGap
        self.noteHeight = noteHeight
        self.pillGap = pillGap
    }

    @discardableResult
    private static func squeeze(_ length: inout CGFloat, to minimum: CGFloat, by overflow: CGFloat) -> CGFloat {
        let cut = min(max(overflow, 0), max(length - minimum, 0))
        length -= cut
        return overflow - cut
    }
}

private struct ProfileV3CustomRuleEditorLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else { return }
        let header = subviews[0]
        let notes = subviews[1]
        let bottom = subviews[2]
        let width = ProposedViewSize(width: bounds.width, height: nil)
        let headerHeight = header.sizeThatFits(width).height
        let bottomHeight = bottom.sizeThatFits(width).height
        let fit = ProfileV3CustomRuleEditorFit(height: bounds.height, header: headerHeight, bottom: bottomHeight)
        var y = bounds.minY
        header.place(at: CGPoint(x: bounds.minX, y: y), proposal: width)
        y += headerHeight + fit.noteGap
        notes.place(
            at: CGPoint(x: bounds.midX, y: y),
            anchor: .top,
            proposal: ProposedViewSize(width: bounds.width, height: fit.noteHeight)
        )
        y += fit.noteHeight + fit.pillGap
        bottom.place(at: CGPoint(x: bounds.midX, y: y), anchor: .top, proposal: width)
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
