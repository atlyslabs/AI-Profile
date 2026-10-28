import ATUIKit
import SwiftUI

struct ProfileV3ProgrammeSourcesView: View {
    @ObservedObject var viewModel: ProfileV3ProgrammeSourcesViewModel
    let onBack: () -> Void

    private typealias Sources = ProfileV3Theme.Sizes.Sources

    var body: some View {
        ZStack(alignment: .top) {
            Color(at: .pureWhite)
                .ignoresSafeArea()
            if let content = viewModel.content {
                ScrollView(showsIndicators: false) {
                    loaded(content)
                }
                .trackScroll(.programmeSources)
            } else {
                ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
                    .frame(maxHeight: .infinity)
            }
            backBar
        }
    }

    private var backBar: some View {
        ZStack {
            HStack {
                ProfileV3CircleIconButton.back(size: ProfileV3Theme.Sizes.navButton, action: onBack)
                Spacer()
            }
            ProfileV3TagLabel(text: ProfileV3Strings.sources)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.topBarInset)
        .padding(.top, ProfileV3Theme.Sizes.topBarTop)
    }

    private func loaded(_ content: ProfileV3PreferenceSources) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(content.title)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.top, ProfileV3Theme.Sizes.hubBarBottom + Sources.titleTop)
            ProfileV3DashedDivider()
                .padding(.top, Sources.dividerTop)
            VStack(spacing: Sources.stepGap) {
                ForEach(content.steps) { step in
                    VStack(spacing: Sources.stepGap) {
                        ProfileV3SourceStepRow(step: step)
                        ProfileV3DashedDivider()
                            .padding(.leading, Sources.tile + Sources.tileSpacing)
                    }
                }
            }
            .padding(.top, Sources.stepsTop)
            .padding(.bottom, Sources.bottomPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
}

#if DEBUG
#Preview("Programme sources") {
    let viewModel = ProfileV3ProgrammeSourcesViewModel(
        programme: ProfileV3ProgrammeFixtures.extraProgrammes[0],
        programID: ProfileV3ProgrammeFixtures.extraProgrammes[0].id,
        profileID: nil,
        repository: ProfileV3MockRepository()
    )
    ProfileV3ProgrammeSourcesView(viewModel: viewModel, onBack: {})
        .task { viewModel.load() }
}
#endif
