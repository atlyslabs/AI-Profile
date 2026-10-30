import ATUIKit
import SwiftUI

struct ProfileV3AIConnectorSheet: View {
    @ObservedObject var model: ProfileV3AIConnectorModel

    private typealias Layout = ProfileV3Theme.Sizes.AIConnector

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3AIConnectorHeader(eyebrow: eyebrow, isClosable: !model.isSaving, onClose: model.close)
            ZStack {
                switch model.step {
                case .detail:
                    ProfileV3AIConnectorDetailContent(model: model)
                        .transition(.opacity)
                case .connect:
                    ProfileV3AIConnectorConnectContent(model: model)
                        .transition(.opacity)
                }
            }
            .animation(ProfileV3Theme.Motion.contentSwitch, value: model.step)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(alignment: .top) {
            ZStack(alignment: .top) {
                Color(at: .pureWhite)
                if model.step == .connect {
                    ProfileV3RainbowGlow(diameter: Layout.wash)
                        .opacity(ProfileV3Theme.Opacity.aiConnectorWash)
                        .offset(y: Layout.washCentreY - Layout.wash / 2)
                        .transition(.opacity)
                }
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
        }
        .profileV3Sheet(.large, isDismissDisabled: model.isSaving)
        .sensoryFeedback(.success, trigger: model.copies)
        .task { model.start() }
        .onDisappear(perform: model.cancel)
    }

    private var eyebrow: String {
        switch model.step {
        case .detail: return model.detail?.eyebrow ?? ""
        case .connect: return model.connect?.eyebrow ?? model.detail?.eyebrow ?? ""
        }
    }
}

private struct ProfileV3AIConnectorHeader: View {
    let eyebrow: String
    let isClosable: Bool
    let onClose: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.AIConnector

    var body: some View {
        ProfileV3AgentSheetChrome(control: .close(onClose), isEnabled: isClosable, accessory: {
            VStack(spacing: Layout.eyebrowGap) {
                ATIcon.SwiftUIImage.settings
                    .profileV3Icon(Layout.gear)
                    .foregroundStyle(Color(at: .pureBlack))
                    .accessibilityHidden(true)
                if !eyebrow.isEmpty {
                    ProfileV3TagLabel(text: eyebrow)
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .padding(.top, Layout.gearTop)
        })
        .frame(height: Layout.headerHeight, alignment: .top)
    }
}

private struct ProfileV3AIConnectorDetailContent: View {
    @ObservedObject var model: ProfileV3AIConnectorModel

    private typealias Layout = ProfileV3Theme.Sizes.AIConnector

    var body: some View {
        if let detail = model.detail, model.detailPhase == .loaded {
            ProfileV3FadingScroll(fadeGap: 0) {
                content(detail)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { cta(detail) }
        } else {
            ProfileV3LoadStateView(phase: model.detailPhase, retry: model.loadDetail)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func content(_ detail: ProfileV3AIConnector) -> some View {
        VStack(spacing: 0) {
            ProfileV3RemoteImage(url: detail.imageURL, contentMode: .fill)
                .frame(width: Layout.logo, height: Layout.logo)
                .clipShape(Circle())
                .accessibilityHidden(true)
                .padding(.top, Layout.logoTop)
            if !detail.title.isEmpty {
                Text(detail.title)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .frame(maxWidth: Layout.titleWidth)
                    .padding(.top, Layout.titleTop)
                    .accessibilityAddTraits(.isHeader)
            }
            if !detail.subtitle.isEmpty {
                Text(detail.subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.aiConnectorSubtitle))
                    .frame(maxWidth: Layout.subtitleWidth)
                    .padding(.top, Layout.subtitleTop)
            }
            if !detail.benefits.isEmpty {
                VStack(alignment: .leading, spacing: Layout.benefitSpacing) {
                    ForEach(detail.benefits) { benefit in
                        ProfileV3AIConnectorBenefitRow(benefit: benefit)
                    }
                }
                .frame(maxWidth: Layout.benefitsWidth, alignment: .leading)
                .padding(.top, Layout.benefitsTop)
            }
            if !detail.disclaimers.isEmpty {
                ProfileV3DashedRule(color: ProfileV3Theme.Palette.dashedRule)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, Layout.dividerTop)
                VStack(alignment: .leading, spacing: Layout.disclaimerSpacing) {
                    ForEach(detail.disclaimers) { disclaimer in
                        ProfileV3AIConnectorDisclaimerText(disclaimer: disclaimer)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Layout.disclaimerInset)
                .padding(.top, Layout.disclaimersTop)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.bottom, Layout.bottom)
    }

    @ViewBuilder
    private func cta(_ detail: ProfileV3AIConnector) -> some View {
        if !detail.ctaLabel.isEmpty {
            ProfileV3SaveBar {
                ProfileV3ContinueButton(
                    title: detail.ctaLabel,
                    tint: Color(at: .pureWhite),
                    fill: ProfileV3Theme.Palette.ink,
                    action: model.getStarted
                )
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            }
        }
    }
}

private struct ProfileV3AIConnectorBenefitRow: View {
    let benefit: ProfileV3AIConnector.Benefit

    private typealias Layout = ProfileV3Theme.Sizes.AIConnector

    var body: some View {
        HStack(alignment: .top, spacing: Layout.benefitGap) {
            ProfileV3StatusDot(kind: .complete)
                .frame(width: Layout.benefitCheck, height: Layout.benefitCheck)
                .padding(.top, Layout.benefitCheckTop)
            VStack(alignment: .leading, spacing: Layout.benefitTextSpacing) {
                Text(benefit.title)
                    .typoGraphy(.H6InterMedium18)
                    .foregroundStyle(Color(at: .pureBlack))
                if !benefit.body.isEmpty {
                    Text(benefit.body)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.aiConnectorSubtitle))
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileV3AIConnectorDisclaimerText: View {
    let disclaimer: ProfileV3AIConnector.Disclaimer

    var body: some View {
        Text(attributed)
            .typoGraphy(.B2InterMedium12)
            .foregroundStyle(Color(at: .pureBlack))
            .tint(Color(at: .pureBlack))
            .multilineTextAlignment(.leading)
            .opacity(ProfileV3Theme.Opacity.aiConnectorDisclaimer)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributed: AttributedString {
        var text = AttributedString(disclaimer.text)
        for link in disclaimer.links {
            guard let range = text.range(of: link.label) else { continue }
            text[range].link = link.url
            text[range].font = Font.Inter.get(size: ProfileV3Theme.Typography.aiConnectorCopySize, weight: .bold)
        }
        return text
    }
}

private struct ProfileV3AIConnectorConnectContent: View {
    @ObservedObject var model: ProfileV3AIConnectorModel

    @FocusState private var isAnswerFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Layout = ProfileV3Theme.Sizes.AIConnector

    var body: some View {
        if let connect = model.connect, model.connectPhase == .loaded {
            ScrollViewReader { proxy in
                ProfileV3FadingScroll(fadeGap: 0) {
                    content(connect)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                    revealAnswer(proxy)
                }
                .onChange(of: isAnswerFocused) {
                    revealAnswer(proxy)
                }
                .onChange(of: model.answer) {
                    revealAnswer(proxy)
                }
                .onChange(of: model.errorMessage) {
                    revealAnswer(proxy)
                }
            }
        } else {
            ProfileV3LoadStateView(phase: model.connectPhase, retry: model.loadConnect)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func content(_ connect: ProfileV3AIConnectorConnect) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: Layout.dotsGap) {
                dots(largeFirst: false)
                ProfileV3RemoteImage(url: connect.imageURL ?? model.detail?.imageURL, contentMode: .fill)
                    .frame(width: Layout.connectLogo, height: Layout.connectLogo)
                    .clipShape(Circle())
                dots(largeFirst: true)
            }
            .accessibilityHidden(true)
            .padding(.top, Layout.connectLogoTop)
            if !connect.title.isEmpty {
                Text(connect.title)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Layout.titleWidth)
                    .padding(.top, Layout.connectTitleTop)
                    .accessibilityAddTraits(.isHeader)
            }
            VStack(alignment: .leading, spacing: Layout.stepSpacing) {
                ForEach(Array(connect.steps.enumerated()), id: \.element.id) { index, step in
                    ProfileV3AIConnectorStepView(
                        model: model,
                        step: step,
                        isLast: index == connect.steps.count - 1,
                        answerFocus: $isAnswerFocused
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, Layout.stepLeading)
            .padding(.trailing, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Layout.stepsTop)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, Layout.bottom)
    }

    private func revealAnswer(_ proxy: ScrollViewProxy) {
        guard isAnswerFocused else { return }
        withAnimation(reduceMotion ? nil : ProfileV3Theme.Motion.expand) {
            proxy.scrollTo(ProfileV3AIConnectorStepView.answerCardID, anchor: .bottom)
        }
    }

    private func dots(largeFirst: Bool) -> some View {
        HStack(spacing: Layout.dotSpacing) {
            Circle()
                .fill(ProfileV3Theme.Palette.lightGrey)
                .frame(width: largeFirst ? Layout.dotLarge : Layout.dotSmall)
            Circle()
                .fill(ProfileV3Theme.Palette.lightGrey)
                .frame(width: largeFirst ? Layout.dotSmall : Layout.dotLarge)
        }
        .frame(height: Layout.dotLarge)
    }
}

private struct ProfileV3AIConnectorStepView: View {
    static let answerCardID = "aiConnector.answerCard"

    @ObservedObject var model: ProfileV3AIConnectorModel
    let step: ProfileV3AIConnectorConnect.Step
    let isLast: Bool
    var answerFocus: FocusState<Bool>.Binding

    private typealias Layout = ProfileV3Theme.Sizes.AIConnector

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3TagLabel(text: step.label)
                .opacity(ProfileV3Theme.Opacity.aiConnectorStepLabel)
                .frame(height: Layout.stepLabelHeight)
            if !step.title.isEmpty {
                Text(step.title)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                    .padding(.top, Layout.stepTitleTop)
                    .accessibilityAddTraits(.isHeader)
            }
            Group {
                if let prompt = step.prompt {
                    promptCard(prompt)
                } else {
                    answerCard
                }
            }
            .padding(.top, Layout.stepCardTop)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topLeading) { timeline }
    }

    private var timeline: some View {
        GeometryReader { proxy in
            let x = Layout.timelineX - Layout.stepLeading
            let centre = Layout.stepLabelHeight / 2
            let end = isLast ? proxy.size.height - Layout.timelineTail : proxy.size.height + Layout.stepSpacing
            ZStack(alignment: .topLeading) {
                ProfileV3DashedRule(color: ProfileV3Theme.Palette.lightGrey, axis: .vertical)
                    .frame(height: max(end, centre) - centre)
                    .offset(x: x - ProfileV3Theme.Stroke.hairline / 2, y: centre)
                Circle()
                    .fill(ProfileV3Theme.Palette.aiConnectorStepDot)
                    .frame(width: Layout.stepDot, height: Layout.stepDot)
                    .offset(x: x - Layout.stepDot / 2, y: centre - Layout.stepDot / 2)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func promptCard(_ prompt: ProfileV3AIConnectorConnect.Prompt) -> some View {
        ZStack(alignment: .topLeading) {
            copyText(prompt.text)
                .padding(.horizontal, Layout.cardPadding)
                .padding(.top, Layout.cardPadding)
                .accessibilityLabel(prompt.text)
            VStack(spacing: 0) {
                ProfileV3Theme.aiConnectorPromptFade
                    .frame(height: Layout.promptFadeHeight)
                ProfileV3Theme.Palette.aiConnectorStrip
            }
            .padding(.top, Layout.promptFadeTop)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            if !model.copyTitle.isEmpty {
                Button(action: model.copyPrompt) {
                    Text(model.copyTitle)
                        .typoGraphy(.B1InterSemibold14)
                        .foregroundStyle(ProfileV3Theme.Palette.aiConnectorCopyText)
                        .padding(.horizontal, Layout.copyHorizontal)
                        .padding(.vertical, Layout.copyVertical)
                        .profileV3Outlined(
                            RoundedRectangle(cornerRadius: Layout.copyRadius, style: .continuous),
                            border: ProfileV3Theme.Palette.aiConnectorBorder,
                            fill: Color(at: .pureWhite)
                        )
                        .contentTransition(.opacity)
                }
                .buttonStyle(.profileV3Pressable)
                .padding(.leading, Layout.cardPadding)
                .padding(.top, Layout.copyTop)
                .animation(ProfileV3Theme.Motion.selection, value: model.isCopied)
                .accessibilityLabel(model.copyTitle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: Layout.promptCardHeight, alignment: .top)
        .background(ProfileV3Theme.aiConnectorCardGradient)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
    }

    private var answerCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !step.body.isEmpty {
                copyText(step.body)
            }
            if let input = step.input {
                TextField(
                    "",
                    text: $model.answer,
                    prompt: Text(input.placeholder).foregroundColor(ProfileV3Theme.Palette.greyPlaceholder),
                    axis: .vertical
                )
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .focused(answerFocus)
                .lineLimit(Layout.pasteMinLines ... Layout.pasteMaxLines)
                .padding(Layout.pastePadding)
                .profileV3Outlined(
                    RoundedRectangle(cornerRadius: Layout.pasteRadius, style: .continuous),
                    border: ProfileV3Theme.Palette.aiConnectorBorder,
                    fill: Color(at: .pureWhite)
                )
                .disabled(model.isSaving)
                .accessibilityLabel(input.placeholder)
                .padding(.top, step.body.isEmpty ? 0 : Layout.bodyGap)
            }
            if let error = model.errorMessage {
                ProfileV3ErrorText(text: error)
                    .padding(.top, Layout.errorTop)
                    .transition(.opacity)
            }
            if let submit = step.submit, !submit.label.isEmpty {
                saveButton(submit.label)
                    .padding(.top, Layout.saveTop)
            }
        }
        .animation(ProfileV3Theme.Motion.selection, value: model.errorMessage)
        .padding(.horizontal, Layout.cardPadding)
        .padding(.top, Layout.cardPadding)
        .padding(.bottom, Layout.cardBottom)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ProfileV3Theme.aiConnectorCardGradient)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
        .padding(.bottom, Layout.revealMargin)
        .id(Self.answerCardID)
        .padding(.bottom, -Layout.revealMargin)
    }

    private func saveButton(_ title: String) -> some View {
        Button(action: model.save) {
            ProfileV3InkPill(
                title: title,
                isLoading: model.isSaving,
                width: .fixed(ProfileV3Theme.Sizes.InkPill.width),
                shadowRadius: ProfileV3Theme.Shadow.softRadius
            )
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(!model.canSave)
        .opacity(model.canSave || model.isSaving ? 1 : ProfileV3Theme.Opacity.disabled)
        .accessibilityLabel(title)
    }

    private func copyText(_ text: String) -> some View {
        Text(text)
            .font(Font.Inter.get(size: ProfileV3Theme.Typography.aiConnectorCopySize, weight: .medium))
            .tracking(ProfileV3Theme.Typography.aiConnectorCopyTracking)
            .lineSpacing(ProfileV3Theme.Typography.aiConnectorCopyLineSpacing)
            .foregroundStyle(Color(at: .pureBlack))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
private struct ProfileV3AIConnectorSheetPreview: View {
    @StateObject private var model = ProfileV3AIConnectorModel(
        connector: "claude",
        repository: ProfileV3MockRepository(delay: .zero),
        onConnected: {},
        onClose: {}
    )
    let connects: Bool

    var body: some View {
        Color.gray
            .sheet(isPresented: .constant(true)) {
                ProfileV3AIConnectorSheet(model: model)
                    .task {
                        model.start()
                        if connects {
                            try? await Task.sleep(for: .milliseconds(50))
                            model.getStarted()
                        }
                    }
            }
    }
}

#Preview("AI connector · detail") {
    ProfileV3AIConnectorSheetPreview(connects: false)
}

#Preview("AI connector · connect") {
    ProfileV3AIConnectorSheetPreview(connects: true)
}
#endif
