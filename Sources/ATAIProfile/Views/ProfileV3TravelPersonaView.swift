import ATUIKit
import SwiftUI

struct ProfileV3TravelPersonaView: View {
    @ObservedObject var viewModel: ProfileV3TravelPersonaViewModel
    @State private var headerPin = ProfileV3HeaderPin()

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(isPresented: showsTrait) {
                    traitDetail
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
                .toolbar(.hidden, for: .navigationBar)
        }
        .interactiveDismissDisabled(viewModel.isDragging)
        .onDisappear(perform: viewModel.cancel)
    }

    private var showsTrait: Binding<Bool> {
        Binding(get: { viewModel.trait != nil }, set: { if !$0 { viewModel.closeTrait() } })
    }

    @ViewBuilder
    private var traitDetail: some View {
        if let trait = viewModel.trait {
            ProfileV3PersonaTraitView(
                viewModel: trait,
                avatarURL: viewModel.content?.iconURL,
                onBack: viewModel.closeTrait
            )
        }
    }

    private var headerOffset: Binding<CGFloat> {
        Binding(get: { headerPin.offset }, set: { headerPin.offset = $0 })
    }

    private var content: some View {
        ZStack(alignment: .top) {
            if viewModel.isDecoding {
                ProfileV3TravelPersonaLoader(
                    persona: viewModel.content,
                    isWaiting: viewModel.phase == .loading,
                    onLoopFinished: viewModel.finishDecodingLoop
                )
                .transition(.opacity)
            } else if let persona = viewModel.content {
                ScrollView(showsIndicators: false) {
                    ProfileV3TravelPersonaContent(persona: persona, viewModel: viewModel)
                        .profileV3ScrollOffsetAnchor(headerOffset)
                }
                .profileV3ScrollOffset(headerOffset)
                .scrollDisabled(viewModel.isDragging)
                .transition(.opacity)
            } else {
                ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
                    .padding(.top, ProfileV3AgentSheetHeader.height(showsOrb: false))
                    .transition(.opacity)
            }
            ProfileV3AgentStickyHeader(tag: viewModel.content?.title ?? "", pin: headerPin, onBack: viewModel.close)
        }
        .animation(ProfileV3Theme.Motion.contentSwitch, value: viewModel.isDecoding)
        .sensoryFeedback(.success, trigger: viewModel.decodedReveals)
        .overlay(alignment: .bottom) {
            if let notice = viewModel.notice {
                ProfileV3Toast(message: notice.message, isError: notice.isError)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.bottom, ProfileV3Theme.Sizes.Persona.toastBottom)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(ProfileV3Theme.Motion.expand, value: viewModel.notice)
        .background(Color(at: .pureWhite))
    }
}

private struct ProfileV3TravelPersonaLoader: View {
    let persona: ProfileV3TravelPersona?
    let isWaiting: Bool
    let onLoopFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Persona = ProfileV3Theme.Sizes.Persona

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ProfileV3TravelPersonaHeader(persona: persona)
                ProfileV3PersonaProcessingCard(traits: ProfileV3Strings.personaLoaderTraits)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, Persona.cardTop)
            }
            .padding(.bottom, Persona.bottom)
            .animation(ProfileV3Theme.Motion.contentSwitch, value: persona != nil)
        }
        .task {
            guard !reduceMotion else { return }
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(ProfileV3Theme.Motion.personaProcessingLoop))
                } catch {
                    return
                }
                onLoopFinished()
            }
        }
        .onChange(of: isWaiting, initial: true) { _, isWaiting in
            if reduceMotion, !isWaiting { onLoopFinished() }
        }
    }
}

private struct ProfileV3TravelPersonaHeader: View {
    let persona: ProfileV3TravelPersona?

    private typealias Persona = ProfileV3Theme.Sizes.Persona
    private typealias Agent = ProfileV3Theme.Sizes.Agent

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3AvatarOrb(imageURL: persona?.iconURL ?? ProfileV3PlaceholderArt.agentPersonal.url, size: Agent.orbLarge)
                .padding(.top, Agent.orbTop)
            if let persona {
                foundTitle(persona.foundLabel)
                    .frame(width: Agent.titleWidth)
                    .padding(.top, ProfileV3Theme.Space.s16)
                    .transition(.opacity)
                if !persona.subtitle.isEmpty {
                    Text(persona.subtitle)
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: Persona.subtitleWidth)
                        .padding(.top, Agent.summaryTop)
                        .transition(.opacity)
                }
            } else {
                Color.clear
                    .frame(
                        height: ProfileV3Theme.Space.s16 + Persona.loadingTitleHeight
                            + Agent.summaryTop + Persona.loadingSubtitleHeight
                    )
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    private func foundTitle(_ label: String) -> some View {
        if let space = label.firstIndex(of: " ") {
            ProfileV3TwoToneTitle(
                lead: String(label[...space]),
                emphasis: String(label[label.index(after: space)...]),
                style: .H5InterMedium20
            )
        } else {
            ProfileV3TwoToneTitle(lead: "", emphasis: label, style: .H5InterMedium20)
        }
    }
}

struct ProfileV3TravelPersonaContent: View {
    let persona: ProfileV3TravelPersona
    @ObservedObject var viewModel: ProfileV3TravelPersonaViewModel

    private typealias Persona = ProfileV3Theme.Sizes.Persona

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3TravelPersonaHeader(persona: persona)
            radarCard
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Persona.cardTop)
        }
        .padding(.bottom, viewModel.isEditable ? Persona.bottom + Persona.toastClearance : Persona.bottom)
        .task {
            do {
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.personaCoachDelayMilliseconds))
            } catch {
                return
            }
            viewModel.startCoach()
        }
    }

    private var radarCard: some View {
        VStack(spacing: 0) {
            ProfileV3PersonaRadar(
                traits: persona.traits,
                range: persona.range,
                score: viewModel.score(of:),
                highlightedID: viewModel.highlightedTraitID,
                coach: viewModel.coach,
                canEdit: viewModel.canEdit,
                onTap: viewModel.tap,
                onOpen: viewModel.open,
                onDragStart: viewModel.beginDrag,
                onDragEnd: viewModel.endDrag,
                onAdjust: viewModel.adjust,
                onCoachTap: viewModel.advanceCoach
            )
            .padding(.top, Persona.radarTop)
            if viewModel.isEditable {
                Text(ProfileV3Strings.personaEditHint)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(ProfileV3Theme.personaCaptionGradient)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: Persona.hintWidth)
                    .padding(.top, Persona.hintTop)
            }
        }
        .padding(.bottom, viewModel.isEditable ? Persona.hintBottom : Persona.cardBottom)
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.selection, trigger: viewModel.highlightedTraitID)
    }
}

#if DEBUG
#Preview("Travel persona") {
    let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: ProfileV3MockRepository())
    viewModel.load()
    return ProfileV3TravelPersonaView(viewModel: viewModel)
}
#endif
