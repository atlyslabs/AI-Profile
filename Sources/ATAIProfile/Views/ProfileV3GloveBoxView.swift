import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxLiveFlow: View {
    let onClose: () -> Void

    @StateObject private var viewModel: ProfileV3GloveBoxViewModel

    init(
        repository: any ProfileV3GloveBoxRepository,
        isKYCComplete: @escaping @MainActor () async -> Bool = { true },
        mainTravellerName: @escaping @MainActor () async -> String? = { nil },
        onCompleteKYC: @escaping () -> Void = {},
        onClose: @escaping () -> Void
    ) {
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: {
            let viewModel = ProfileV3GloveBoxViewModel(
                repository: repository,
                isKYCComplete: isKYCComplete,
                mainTravellerName: mainTravellerName
            )
            viewModel.onIntroAction = { action in
                if action == .completeKYC { onCompleteKYC() }
            }
            return viewModel
        }())
    }

    var body: some View {
        ProfileV3GloveBoxView(viewModel: viewModel, onBack: onClose)
    }
}

struct ProfileV3GloveBoxView: View {
    @ObservedObject var viewModel: ProfileV3GloveBoxViewModel
    let onBack: () -> Void

    @State private var sheetPresenter = ProfileV3GloveBoxSheetPresenter()

    var body: some View {
        Group {
            if viewModel.isResolvingScreen {
                resolving
            } else {
                page
            }
        }
            .blur(radius: viewModel.sheets.isEmpty ? 0 : ProfileV3Theme.GloveBox.Layout.dimBlur)
            .accessibilityHidden(!viewModel.sheets.isEmpty)
            .background(Color(at: .pureWhite).ignoresSafeArea())
            .sensoryFeedback(.success, trigger: viewModel.copies)
            .onChange(of: viewModel.sheets.isEmpty) { _, _ in
                sheetPresenter.update(for: viewModel)
            }
            .onDisappear {
                sheetPresenter.dismiss()
            }
    }

    private var resolving: some View {
        ZStack(alignment: .top) {
            ProfileV3LoadStateView(phase: .loading, retry: {})
            ProfileV3GloveBoxHeader(onBack: onBack)
        }
    }

    @ViewBuilder
    private var page: some View {
        switch viewModel.gloveBox.stage {
        case .intro(let intro):
            ProfileV3GloveBoxIntroView(
                title: viewModel.gloveBox.title,
                intro: intro,
                onBack: onBack,
                onAction: viewModel.tapIntroAction
            )
            .id(intro)
            .transition(.opacity)
        case .home(let home):
            ProfileV3GloveBoxHomeView(title: viewModel.gloveBox.title, home: home, viewModel: viewModel, onBack: onBack)
                .transition(.opacity)
        }
    }
}

struct ProfileV3GloveBoxHeader: View {
    var title: String?
    var titleOpacity: Double = 1
    let onBack: () -> Void

    var body: some View {
        ZStack {
            if let title {
                ProfileV3TagLabel(text: title)
                    .opacity(titleOpacity)
                    .accessibilityHidden(titleOpacity == 0)
            }
            HStack {
                ProfileV3CircleIconButton.back(action: onBack)
                Spacer()
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.GloveBox.Layout.headerTop)
    }
}

struct ProfileV3GloveBoxIntroView: View {
    let title: String
    let intro: ProfileV3GloveBoxIntro
    var animatesTitle = true
    let onBack: () -> Void
    let onAction: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3GloveBoxHeader(onBack: onBack)
            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    ProfileV3GloveBoxIntroContent(
                        title: title,
                        intro: intro,
                        scale: Layout.cabinetScale(for: proxy.size.width),
                        animatesTitle: animatesTitle
                    )
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            if !intro.actionTitle.isEmpty {
                ProfileV3GloveBoxActionButton(title: intro.actionTitle, action: onAction)
                    .padding(.horizontal, Layout.actionInset)
                    .padding(.bottom, Layout.actionBottom)
            }
        }
    }
}

struct ProfileV3GloveBoxIntroContent: View {
    let title: String
    let intro: ProfileV3GloveBoxIntro
    let scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appearedAt = Date()
    @State private var isTitleSettled: Bool

    init(title: String, intro: ProfileV3GloveBoxIntro, scale: CGFloat, animatesTitle: Bool = true) {
        self.title = title
        self.intro = intro
        self.scale = scale
        _isTitleSettled = State(initialValue: !animatesTitle || intro.status != .warmingUp)
    }

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Motion = ProfileV3Theme.GloveBox.Motion

    var body: some View {
        ZStack(alignment: .top) {
            ProfileV3GloveBoxCabinet(title: title, status: intro.status, statusLabel: intro.statusLabel, scale: scale)
            copy
                .padding(.top, Layout.introTitleTop * scale)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Layout.introCabinetTop)
        .padding(.bottom, Layout.introBottom)
        .task {
            guard !isTitleSettled else { return }
            if !reduceMotion {
                try? await Task.sleep(for: .seconds(Motion.titleDuration))
            }
            isTitleSettled = true
        }
    }

    private var copy: some View {
        VStack(spacing: Layout.introSubtitleGap) {
            if !intro.title.isEmpty {
                TimelineView(.animation(paused: isTitleSettled || reduceMotion)) { context in
                    let time = isTitleSettled || reduceMotion ? .infinity : context.date.timeIntervalSince(appearedAt)
                    Text(intro.title)
                        .typoGraphy(.H3DentonMedium28)
                        .foregroundStyle(Color(at: .pureBlack))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: Layout.introTitleWidth(intro.status))
                        .opacity(Motion.titleFade.value(at: time))
                        .offset(y: Motion.titleRise.value(at: time))
                }
                .accessibilityAddTraits(.isHeader)
            }
            if !intro.subtitle.isEmpty {
                Text(intro.subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.aboutOpacity))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Layout.introSubtitleWidth)
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
}

struct ProfileV3GloveBoxHomeView: View {
    let title: String
    let home: ProfileV3GloveBoxHome
    @ObservedObject var viewModel: ProfileV3GloveBoxViewModel
    var revealsSheet = true
    let onBack: () -> Void

    @State private var headerPin = ProfileV3HeaderPin()

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3GloveBoxHeader(title: title, titleOpacity: headerPin.progress, onBack: onBack)
            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    ProfileV3GloveBoxHomeContent(
                        title: title,
                        home: home,
                        viewModel: viewModel,
                        scale: ProfileV3Theme.GloveBox.Layout.cabinetScale(for: proxy.size.width),
                        revealsSheet: revealsSheet
                    )
                    .profileV3HeaderFadeAnchor(headerPin)
                }
                .profileV3HeaderFade(headerPin)
            }
        }
    }
}

struct ProfileV3GloveBoxHomeContent: View {
    let title: String
    let home: ProfileV3GloveBoxHome
    @ObservedObject var viewModel: ProfileV3GloveBoxViewModel
    let scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appearedAt = Date()
    @State private var isRevealDone: Bool

    init(
        title: String,
        home: ProfileV3GloveBoxHome,
        viewModel: ProfileV3GloveBoxViewModel,
        scale: CGFloat,
        revealsSheet: Bool = true
    ) {
        self.title = title
        self.home = home
        self.viewModel = viewModel
        self.scale = scale
        _isRevealDone = State(initialValue: !revealsSheet)
    }

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Motion = ProfileV3Theme.GloveBox.Motion

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3GloveBoxCabinet(title: title, scale: scale)
                .padding(.top, Layout.homeCabinetTop)
            TimelineView(.animation(paused: isRevealDone || reduceMotion)) { context in
                sheet(at: isRevealDone || reduceMotion ? .infinity : context.date.timeIntervalSince(appearedAt))
            }
            .padding(.top, (Layout.homeSheetTop - Layout.cabinet.height) * scale)
        }
        .frame(maxWidth: .infinity)
        .task {
            guard !isRevealDone else { return }
            if !reduceMotion {
                try? await Task.sleep(for: .seconds(Motion.sheet.end))
            }
            isRevealDone = true
        }
    }

    private func sheet(at time: Double) -> some View {
        VStack(spacing: Layout.sectionSpacing) {
            ProfileV3GloveBoxEmailSectionView(
                section: home.email,
                isCopied: viewModel.copied == .address,
                onCopy: { viewModel.copy(.address) },
                onOpen: { viewModel.open(.email($0)) },
                onViewAll: { viewModel.openList(.emails) },
                forwardingDraft: $viewModel.forwardingDraft,
                isUpdatingForwarding: viewModel.isUpdatingForwarding,
                forwardingError: viewModel.forwardingError,
                onToggleForwarding: viewModel.toggleForwarding,
                onSendForwarding: viewModel.sendForwardingAddress
            )
            if ProfileV3FeatureFlags.isGloveBoxPhoneNumberEnabled {
                ProfileV3GloveBoxPhoneSectionView(
                    section: home.phone,
                    isCopied: viewModel.copied == .number,
                    onCopy: { viewModel.copy(.number) },
                    onOpen: { viewModel.open(.call($0)) },
                    onViewAll: { viewModel.openList(.calls) }
                )
            }
            if ProfileV3FeatureFlags.isGloveBoxVirtualCardEnabled {
                ProfileV3GloveBoxCardSectionView(
                    section: home.card,
                    showsNotice: viewModel.showsCardNotice,
                    onTapCard: viewModel.showCardNotice,
                    onCloseNotice: viewModel.hideCardNotice,
                    onSelectOption: viewModel.selectPayOption,
                    onAddCard: viewModel.tapAddCard,
                    onOpen: { viewModel.open(.transaction($0)) },
                    onViewAll: { viewModel.openList(.transactions) }
                )
            }
        }
        .padding(Layout.sheetPadding)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: Layout.sheetRadius,
                topTrailingRadius: Layout.sheetRadius,
                style: .continuous
            )
            .fill(Color(at: .pureWhite))
            .shadow(
                color: ProfileV3Theme.GloveBox.Palette.sheetShadow,
                radius: Layout.sheetShadowRadius,
                y: Layout.sheetShadowY
            )
        )
        .opacity(Motion.sheet.progress(at: time))
        .offset(y: Motion.sheet.offset(at: time))
    }
}

struct ProfileV3GloveBoxSectionCard<Content: View>: View {
    let icon: Image
    let title: String
    var badge: ProfileV3GloveBoxBadge?
    var viewAllTitle: String?
    var onViewAll: () -> Void = {}
    @ViewBuilder let content: Content

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Layout.sectionRadius, style: .continuous)
        VStack(alignment: .leading, spacing: 0) {
            header
            content
            if let viewAllTitle, !viewAllTitle.isEmpty {
                ProfileV3GloveBoxViewAll(title: viewAllTitle, action: onViewAll)
                    .padding(.top, Layout.viewAllTop)
            }
        }
        .padding(.top, Layout.sectionTop)
        .padding(.leading, Layout.sectionLeading)
        .padding(.trailing, Layout.sectionTrailing)
        .padding(.bottom, viewAllTitle?.isEmpty == false ? Layout.viewAllBottom : Layout.sectionBottom)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(shape.fill(ProfileV3Theme.GloveBox.sectionFill))
        .overlay(shape.strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
        .shadow(color: Palette.sectionShadow, radius: Layout.sectionShadowRadius, y: Layout.sectionShadowY)
    }

    private var header: some View {
        HStack(spacing: Layout.sectionIconGap) {
            icon
                .profileV3Icon(Layout.sectionIcon)
                .foregroundStyle(Palette.dialIcon)
            Text(title)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
                .foregroundStyle(Color(at: .pureBlack).opacity(Palette.sectionTitleOpacity))
            Spacer(minLength: ProfileV3Theme.Space.s8)
            if let badge {
                ProfileV3GloveBoxBadgeView(badge: badge)
            }
        }
        .frame(minHeight: Layout.badgeHeight)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct ProfileV3GloveBoxEmailSectionView: View {
    let section: ProfileV3GloveBoxEmailSection
    let isCopied: Bool
    let onCopy: () -> Void
    let onOpen: (ProfileV3GloveBoxEmail) -> Void
    let onViewAll: () -> Void
    var forwardingDraft: Binding<String> = .constant("")
    var isUpdatingForwarding = false
    var forwardingError: String?
    var onToggleForwarding: () -> Void = {}
    var onSendForwarding: () -> Void = {}

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        ProfileV3GloveBoxSectionCard(
            icon: ATIcon.SwiftUIImage.mail,
            title: section.title,
            badge: section.badge,
            viewAllTitle: section.viewAllTitle,
            onViewAll: onViewAll
        ) {
            ProfileV3GloveBoxCopyValue(value: section.address, isCopied: isCopied, onCopy: onCopy)
                .padding(.top, Layout.sectionValueTop)
            if !section.about.isEmpty {
                Text(section.about)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(Palette.aboutOpacity))
                    .frame(maxWidth: Layout.sectionAboutWidth, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Layout.sectionAboutTop)
            }
            if let forwardingAddress = section.forwardingAddress, !section.forwardingLabel.isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: Layout.valueSpacing) {
                    Text("\(Text(section.forwardingLabel).foregroundStyle(Color(at: .pureBlack).opacity(Palette.forwardingLabelOpacity))) \(Text(forwardingAddress).foregroundStyle(Color(at: .pureBlack)))")
                        .typoGraphy(.B2InterMedium12)
                        .opacity(Palette.forwardingOpacity)
                        .fixedSize(horizontal: false, vertical: true)
                    if section.canPauseForwarding {
                        forwardingAction(
                            section.forwardingPaused ? ProfileV3GloveBoxCopy.resume : ProfileV3GloveBoxCopy.pause,
                            isEnabled: !isUpdatingForwarding,
                            action: onToggleForwarding
                        )
                    }
                }
                .padding(.top, Layout.forwardingTop)
            }
            if section.canSetForwardingAddress {
                HStack(alignment: .firstTextBaseline, spacing: Layout.valueSpacing) {
                    TextField(ProfileV3GloveBoxCopy.forwarding, text: forwardingDraft)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .pureBlack))
                    forwardingAction(
                        ProfileV3GloveBoxCopy.sendLink,
                        isEnabled: !isUpdatingForwarding && !forwardingDraft.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        action: onSendForwarding
                    )
                }
                .padding(.top, Layout.forwardingTop)
            }
            if let forwardingError, !forwardingError.isEmpty {
                Text(forwardingError)
                    .typoGraphy(.T1InterBold11)
                    .foregroundStyle(ProfileV3Theme.Palette.error)
                    .padding(.top, ProfileV3Theme.Space.s8)
            }
            if let notice = section.forwardingNotice {
                forwardingNotice(notice)
                    .padding(.top, Layout.forwardingNoticeTop)
            }
            let emails = Array(section.emails.prefix(Layout.emailPreviewLimit))
            if !emails.isEmpty {
                ProfileV3GloveBoxPreviewCard(sampleLabel: section.sampleLabel) {
                    VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                        ForEach(Array(emails.enumerated()), id: \.element.id) { index, email in
                            if index > 0 {
                                ProfileV3GloveBoxRowDivider(inset: Layout.logo + Layout.rowGap)
                            }
                            ProfileV3GloveBoxEmailRow(email: email) { onOpen(email) }
                        }
                    }
                }
                .padding(.top, Layout.previewTop)
            }
        }
    }

    private func forwardingNotice(_ notice: String) -> some View {
        let shape = RoundedRectangle(cornerRadius: Layout.forwardingNoticeRadius, style: .continuous)
        return HStack(alignment: .top, spacing: Layout.valueSpacing) {
            ATIcon.SwiftUIImage.infoOutline
                .profileV3Icon(Layout.forwardingNoticeIcon)
                .foregroundStyle(Palette.icon.opacity(Palette.metaIconOpacity))
            Text(notice)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(Palette.attentionOpacity))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Layout.forwardingNoticePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(shape.fill(Palette.preview))
        .overlay(shape.strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
        .accessibilityElement(children: .combine)
    }

    private func forwardingAction(_ title: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Palette.control)
                .opacity(isEnabled ? 1 : ProfileV3Theme.Motion.disabledOpacity)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .disabled(!isEnabled)
    }
}

struct ProfileV3GloveBoxPhoneSectionView: View {
    let section: ProfileV3GloveBoxPhoneSection
    let isCopied: Bool
    let onCopy: () -> Void
    let onOpen: (ProfileV3GloveBoxCall) -> Void
    let onViewAll: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        ProfileV3GloveBoxSectionCard(
            icon: ATIcon.SwiftUIImage.call,
            title: section.title,
            badge: section.badge,
            viewAllTitle: section.viewAllTitle,
            onViewAll: onViewAll
        ) {
            ProfileV3GloveBoxCopyValue(
                value: section.number.value,
                countryCode: section.number.countryCode,
                isCopyable: section.number.isCopyable,
                isCopied: isCopied,
                spacing: Layout.copyGap,
                onCopy: onCopy
            )
            .padding(.top, Layout.sectionValueTop)
            if let headline = section.headline {
                Text("\(faded(headline.lead))\(Text(headline.emphasis).foregroundStyle(Color(at: .pureBlack)))\(faded(headline.trail))")
                    .typoGraphy(.H7InterMedium16)
                    .frame(maxWidth: Layout.headlineWidth, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Layout.headlineTop)
                about
                    .padding(.top, Layout.leadTop)
            } else {
                about
                    .padding(.top, Layout.phoneAboutTop)
            }
            if let call = section.calls.first {
                ProfileV3GloveBoxPreviewCard(sampleLabel: section.sampleLabel) {
                    ProfileV3GloveBoxCallRow(call: call, pillWidth: Layout.audioPreviewWidth) { onOpen(call) }
                }
                .padding(.top, Layout.previewTop)
            }
        }
    }

    @ViewBuilder
    private var about: some View {
        if !section.about.isEmpty {
            Text(section.about)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(Palette.aboutOpacity))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func faded(_ text: String) -> Text {
        Text(text).foregroundStyle(Color(at: .pureBlack).opacity(Palette.aboutOpacity))
    }
}

#if DEBUG
#Preview("Glove box · locked") {
    ProfileV3GloveBoxView(
        viewModel: ProfileV3GloveBoxViewModel(gloveBox: ProfileV3GloveBoxFixtures.Start.unlock.gloveBox)
    ) {}
}

#Preview("Glove box · home") {
    ProfileV3GloveBoxView(
        viewModel: ProfileV3GloveBoxViewModel(gloveBox: ProfileV3GloveBoxFixtures.Start.home.gloveBox)
    ) {}
}
#endif
