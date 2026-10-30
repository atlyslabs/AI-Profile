import ATUIKit
import SwiftUI

struct ProfileV3CustomRulesSection: View {
    @ObservedObject var model: ProfileV3CustomRulesModel
    var onReveal: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Sizes = ProfileV3Theme.Sizes.CustomRules
    private static let rowStartID = "customRules.rowStart"

    var body: some View {
        if !model.field.rules.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ProfileV3SectionHeader(title: model.title, status: .complete)
                ScrollViewReader { row in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Sizes.cardSpacing) {
                            ForEach(model.cards) { rule in
                                ProfileV3CustomRuleCard(text: rule.text, hint: model.field.editor.editTitle) {
                                    model.startEditing(rule)
                                }
                            }
                        }
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .id(Self.rowStartID)
                    }
                    .onChange(of: model.reveals) {
                        withAnimation(reduceMotion ? nil : ProfileV3Theme.Motion.scrollReveal) {
                            row.scrollTo(Self.rowStartID, anchor: .leading)
                            onReveal()
                        }
                    }
                }
                .padding(.horizontal, -ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sizes.cardsTop)
            }
        }
    }
}

struct ProfileV3CustomRuleCard: View {
    let text: String
    var hint = ""
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
        .accessibilityHint(hint)
    }
}

struct ProfileV3CustomRuleNote<Content: View>: View {
    enum Style {
        case front
        case back
    }

    var style = Style.front
    var label = ""
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
            Text(label)
                .profileV3MonoLabel()
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
        .animation(ProfileV3Theme.Motion.expand, value: model.editor)
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
            ProfileV3FrostedBackdrop(tint: Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.ruleBackdrop))
        }
        .animation(ProfileV3Theme.Motion.saveState, value: model.phase)
        .animation(ProfileV3Theme.Motion.saveState, value: model.canSave)
        .sensoryFeedback(.success, trigger: model.phase) { _, phase in phase == .saved }
        .sensoryFeedback(.error, trigger: model.errorMessage) { _, message in message != nil }
        .onAppear { isFocused = true }
        .sheet(isPresented: $model.confirmsDelete) {
            ProfileV3CustomRuleDeleteSheet(model: model)
        }
    }

    private var header: some View {
        ProfileV3AgentSheetChrome(control: .back(model.close), showsGrabber: false, title: {
            Text(editor.isAdding ? model.field.editor.addTitle : model.field.editor.editTitle)
                .typoGraphy(.H5InterSemibold20)
                .foregroundStyle(Color(at: .pureBlack))
                .accessibilityAddTraits(.isHeader)
        })
    }

    private var notes: some View {
        ZStack {
            ProfileV3CustomRuleNote(style: .back) { EmptyView() }
                .opacity(ProfileV3Theme.Opacity.ruleBackNote)
                .rotationEffect(.degrees(Sizes.backTilt))
                .accessibilityHidden(true)
            ProfileV3CustomRuleNote(label: model.field.editor.noteLabel) {
                TextField("", text: Binding(get: { model.draft }, set: model.setDraft), axis: .vertical)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(ProfileV3Theme.Palette.ink)
                    .tint(ProfileV3Theme.Palette.ink)
                    .focused($isFocused)
                    .disabled(model.phase != .idle)
                    .accessibilityLabel(model.field.editor.noteLabel)
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
        Button(action: model.requestDelete) {
            ATIcon.SwiftUIImage.delete
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(ProfileV3Theme.Palette.ruleTrash)
                .frame(width: Sizes.trash, height: Sizes.trash)
                .background(Circle().fill(Color(at: .pureWhite)))
                .overlay(Circle().strokeBorder(ProfileV3Theme.Palette.ruleTrashBorder, lineWidth: ProfileV3Theme.Stroke.thin))
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .disabled(model.phase != .idle)
        .accessibilityLabel(ProfileV3Strings.deleteRule)
    }

    @ViewBuilder
    private var bottom: some View {
        VStack(spacing: ProfileV3Theme.Space.s12) {
            if let error = model.errorMessage {
                ProfileV3ErrorText(text: error)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
            if editor.isAdding {
                if model.phase == .saved {
                    ProfileV3InkPill(title: model.field.editor.savedToast, shadowRadius: Sizes.pillShadowRadius)
                        .transition(.opacity)
                        .accessibilityAddTraits(.updatesFrequently)
                } else if model.canSave || model.phase == .saving {
                    Button(action: model.save) {
                        ProfileV3InkPill(
                            title: model.field.editor.saveLabel,
                            isLoading: model.phase == .saving,
                            shadowRadius: Sizes.pillShadowRadius
                        )
                    }
                    .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
                    .disabled(model.phase != .idle)
                    .profileV3SaveEntrance()
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                }
            } else if model.canSave || model.phase != .idle {
                ProfileV3SaveButton(
                    phase: model.phase,
                    title: ProfileV3Strings.saveChanges,
                    savedTitle: model.field.editor.savedToast,
                    action: model.save
                )
                .profileV3SaveEntrance()
                .transition(.asymmetric(insertion: .identity, removal: .opacity))
            }
        }
        .frame(minHeight: ProfileV3Theme.Sizes.InkPill.height, alignment: .top)
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

struct ProfileV3CustomRuleDeleteSheet: View {
    @ObservedObject var model: ProfileV3CustomRulesModel

    var body: some View {
        ProfileV3FittedConfirmationSheet(cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius, isBusy: model.phase == .saving) {
            ProfileV3ConfirmationView.deleteRule(
                model.field.deleteConfirm,
                isDeleting: model.phase == .saving,
                onBack: model.cancelDelete,
                onConfirm: model.confirmDelete
            )
        }
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
        ProfileV3CustomRuleNote(label: "NOTE") {
            Text("Pick a veg restaurant every time Aakanksha is on the trip. Make sure the veg food doesn’t have egg")
                .typoGraphy(.H7InterMedium16)
        }
    }
    .padding(ProfileV3Theme.Space.s40)
    .background(Color(at: .pureWhite))
}

extension ProfileV3CustomRulesModel {
    static var preview: ProfileV3CustomRulesModel {
        ProfileV3CustomRulesModel(
            title: "CUSTOM RULES",
            field: ProfileV3AgentFixtures.customRulesField([
                "Pick a veg restaurant every time. Aakanksha is on the trip. Make sure the veg food doesn’t have egg"
            ])
        ) { _ in .saved }
    }
}
#endif
