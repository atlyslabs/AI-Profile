import ATUIKit
import SwiftUI

struct ProfileV3HouseholdApplySheet: View {
    @ObservedObject var viewModel: ProfileV3AgentFormViewModel

    var body: some View {
        if let session = viewModel.householdApply {
            sheet(session)
        }
    }

    private func sheet(_ session: ProfileV3HouseholdApplySession) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                header(session)
                Text(session.prompt.title)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(width: ProfileV3Theme.Sizes.Agent.titleWidth)
                    .padding(.top, ProfileV3Theme.Space.s24)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing: ProfileV3Theme.Sizes.Traveller.cardSpacing) {
                    ForEach(session.prompt.travellers) { traveller in
                        row(traveller, session: session)
                    }
                }
                .padding(.top, ProfileV3Theme.Space.s32)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) { bar(session) }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .sensoryFeedback(.success, trigger: session.phase) { _, phase in phase == .saved }
    }

    private func header(_ session: ProfileV3HouseholdApplySession) -> some View {
        ZStack(alignment: .top) {
            ProfileV3SheetGrabber(
                width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                color: Color(at: .neutralGrey200),
                top: ProfileV3Theme.Space.s10
            )
            ProfileV3TagLabel(text: session.prompt.eyebrow)
                .padding(.top, ProfileV3Theme.Sizes.Agent.tagTop)
            HStack {
                Spacer()
                ProfileV3CircleIconButton.close(action: viewModel.closeHousehold)
                    .disabled(session.phase == .saving || session.phase == .saved)
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
            ProfileV3AvatarOrb(
                imageURL: session.prompt.iconURL ?? viewModel.avatarURL,
                size: ProfileV3Theme.Sizes.Agent.orbLarge
            )
            .padding(.top, ProfileV3Theme.Sizes.Agent.orbTop)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .frame(
            height: ProfileV3Theme.Sizes.Agent.orbTop + ProfileV3Theme.Sizes.Agent.orbLarge,
            alignment: .top
        )
    }

    private func row(
        _ traveller: ProfileV3HouseholdPrompt.Traveller,
        session: ProfileV3HouseholdApplySession
    ) -> some View {
        let isSelected = session.selection.contains(traveller.id)
        return Button { viewModel.toggleHouseholdTraveller(traveller.id) } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxl, style: .continuous)
                    .fill(ProfileV3Theme.Palette.travellerCard)
                VStack(alignment: .leading, spacing: 0) {
                    Text(traveller.name)
                        .typoGraphy(.H7InterMedium16)
                        .foregroundStyle(Color(at: .pureWhite))
                        .opacity(isSelected ? 1 : ProfileV3Theme.Opacity.optionUnselected)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    ProfileV3PassNumber(number: traveller.passNumber)
                }
                .padding(.leading, ProfileV3Theme.Space.s30)
                .padding(.vertical, ProfileV3Theme.Space.s22)
                checkbox(isSelected)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, ProfileV3Theme.Space.s30)
            }
            .frame(height: ProfileV3Theme.Sizes.Traveller.cardHeight)
            .shadow(
                color: ProfileV3Theme.Palette.shadow,
                radius: ProfileV3Theme.Shadow.cardRadius,
                y: ProfileV3Theme.Shadow.cardY
            )
            .contentShape(
                RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxl, style: .continuous)
            )
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(session.phase == .saving || session.phase == .saved)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(traveller.name)
    }

    private func checkbox(_ isSelected: Bool) -> some View {
        (isSelected ? ATIcon.SwiftUIImage.checkBox : ATIcon.SwiftUIImage.checkBoxOutlineBlank)
            .profileV3Icon(ProfileV3Theme.Sizes.Picker.checkbox)
            .foregroundStyle(Color(at: .pureWhite))
            .frame(
                width: ProfileV3Theme.Sizes.Picker.checkbox,
                height: ProfileV3Theme.Sizes.Picker.checkbox
            )
            .accessibilityHidden(true)
    }

    private func bar(_ session: ProfileV3HouseholdApplySession) -> some View {
        ZStack(alignment: .bottom) {
            ProfileV3SaveBarFade()
            VStack(spacing: ProfileV3Theme.Space.s12) {
                if let message = session.errorMessage {
                    Text(message)
                        .typoGraphy(.T1InterBold11)
                        .foregroundStyle(ProfileV3Theme.Palette.error)
                        .multilineTextAlignment(.center)
                }
                ProfileV3SaveButton(
                    phase: savePhase(session),
                    title: session.prompt.confirmLabel,
                    savedTitle: session.doneLabel,
                    action: viewModel.confirmHousehold
                )
                .disabled(!session.canConfirm && session.phase != .saving && session.phase != .saved)
                .opacity(session.canConfirm || session.phase == .saving || session.phase == .saved ? 1 : ProfileV3Theme.Motion.disabledOpacity)
            }
            .animation(ProfileV3Theme.Motion.saveState, value: session.phase)
            .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
        }
    }

    private func savePhase(_ session: ProfileV3HouseholdApplySession) -> ProfileV3SavePhase {
        switch session.phase {
        case .choosing, .failed: return .idle
        case .saving: return .saving
        case .saved: return .saved
        }
    }
}
