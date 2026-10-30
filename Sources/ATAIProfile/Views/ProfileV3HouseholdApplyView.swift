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
        ProfileV3AgentSheetHeader(
            tag: session.prompt.eyebrow,
            avatarURL: session.prompt.iconURL ?? viewModel.avatarURL,
            isEnabled: session.phase != .saving && session.phase != .saved,
            control: .close(viewModel.closeHousehold)
        )
    }

    private func row(
        _ traveller: ProfileV3HouseholdPrompt.Traveller,
        session: ProfileV3HouseholdApplySession
    ) -> some View {
        let isSelected = session.selection.contains(traveller.id)
        return Button { viewModel.toggleHouseholdTraveller(traveller.id) } label: {
            ProfileV3TravellerCardShell(passNumber: traveller.passNumber) {
                Text(traveller.name)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureWhite))
                    .opacity(isSelected ? 1 : ProfileV3Theme.Opacity.optionUnselected)
                    .lineLimit(1)
            } trailing: {
                ProfileV3CheckboxMark(
                    isSelected: isSelected,
                    size: ProfileV3Theme.Sizes.Picker.checkbox,
                    tint: Color(at: .pureWhite)
                )
            }
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(session.phase == .saving || session.phase == .saved)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(traveller.name)
    }

    private func bar(_ session: ProfileV3HouseholdApplySession) -> some View {
        ProfileV3SaveBar(error: session.errorMessage) {
            ProfileV3SaveButton(
                phase: session.phase,
                title: session.prompt.confirmLabel,
                savedTitle: session.doneLabel,
                action: viewModel.confirmHousehold
            )
            .disabled(!session.canConfirm && session.phase != .saving && session.phase != .saved)
            .opacity(session.canConfirm || session.phase == .saving || session.phase == .saved ? 1 : ProfileV3Theme.Opacity.disabled)
        }
        .animation(ProfileV3Theme.Motion.saveState, value: session.phase)
    }
}
