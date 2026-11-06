#if DEBUG
import ATUIKit
import SwiftUI

struct ProfileV3SettingsDebugSection: View {
    let onOpenCityProfile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s16) {
            ProfileV3DashedDivider()
            ProfileV3TagLabel(text: "Debug")
            ProfileV3SettingsRow(icon: ATIcon.SwiftUIImage.locationCity, title: "City profile", action: onOpenCityProfile)
            Text("Opens City profile on this account's real data.")
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .neutralGrey400))
        }
    }
}

struct ProfileV3GloveBoxDebugFlow: View {
    let onClose: () -> Void

    @StateObject private var viewModel: ProfileV3GloveBoxViewModel

    init(start: ProfileV3GloveBoxFixtures.Start, onClose: @escaping () -> Void) {
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: ProfileV3GloveBoxViewModel(gloveBox: start.gloveBox))
    }

    var body: some View {
        ProfileV3GloveBoxView(viewModel: viewModel, onBack: onClose)
            .onAppear(perform: wire)
    }

    private func wire() {
        let viewModel = viewModel
        viewModel.onIntroAction = { [weak viewModel] action in
            switch action {
            case .completeKYC: viewModel?.show(.intro(ProfileV3GloveBoxFixtures.warmingUp))
            case .activate: viewModel?.show(.home(ProfileV3GloveBoxFixtures.sampleHome))
            }
        }
        viewModel.onFollowUp = { [weak viewModel] _ in viewModel?.dismissSheets() }
    }
}

#Preview("Settings debug section") {
    ScrollView {
        ProfileV3SettingsDebugSection {}
            .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
    .background(Color(at: .pureWhite))
}

#Preview("Glove box · unlock") {
    ProfileV3GloveBoxDebugFlow(start: .unlock) {}
}

#Preview("Glove box · active") {
    ProfileV3GloveBoxDebugFlow(start: .home) {}
}

#Preview("Glove box · sample") {
    ProfileV3GloveBoxDebugFlow(start: .homeSample) {}
}
#endif
