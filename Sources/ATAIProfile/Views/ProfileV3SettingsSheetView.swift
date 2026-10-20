import ATUIKit
import SwiftUI

struct ProfileV3SettingsSheetView: View {
    @Bindable var viewModel: ProfileV3SettingsViewModel
    let entry: ProfileV3SettingsDestination
    var maxHeight: CGFloat = ProfileV3Theme.Sizes.sheetFallbackHeight
    var bottomInset: CGFloat = 0
    @State private var metrics: ProfileV3SheetMetrics

    init(
        viewModel: ProfileV3SettingsViewModel,
        entry: ProfileV3SettingsDestination,
        maxHeight: CGFloat = ProfileV3Theme.Sizes.sheetFallbackHeight,
        bottomInset: CGFloat = 0
    ) {
        self.viewModel = viewModel
        self.entry = entry
        self.maxHeight = maxHeight
        self.bottomInset = bottomInset
        _metrics = State(initialValue: ProfileV3SheetMetrics(destinationHeights: viewModel.sheetHeights))
    }

    private var root: ProfileV3SettingsDestination { viewModel.sheetEntry ?? entry }

    var body: some View {
        NavigationStack(path: $viewModel.sheetPath) {
            sized(root)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: ProfileV3SettingsDestination.self) { destination in
                    sized(destination)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        .frame(height: maxHeight - bottomInset)
        .frame(height: visibleHeight - bottomInset, alignment: .top)
        .clipped()
        .padding(.bottom, bottomInset)
        .background(Color(at: .pureWhite))
        .profileV3TapToDismissKeyboard()
    }

    private var visibleHeight: CGFloat {
        metrics.height(for: viewModel.sheetPath.last ?? root, maxHeight: maxHeight, bottomInset: bottomInset)
    }

    @ViewBuilder
    private func sized(_ destination: ProfileV3SettingsDestination) -> some View {
        let screen = ProfileV3SettingsDestinationView(destination: destination, viewModel: viewModel)
        if destination.isFullHeight {
            screen.profileV3KeyboardLift(clearance: bottomInset)
        } else {
            screen.modifier(ProfileV3DestinationHeightReporter(height: height(of: destination)))
        }
    }

    private func height(of destination: ProfileV3SettingsDestination) -> Binding<CGFloat?> {
        Binding(
            get: { metrics.destinationHeights[destination] },
            set: { metrics.destinationHeights[destination] = $0 }
        )
    }
}

#if DEBUG
#Preview("Settings sheet · logout") {
    ProfileV3SettingsSheetView(viewModel: .preview(), entry: .logout)
}

#Preview("Settings sheet · residence") {
    ProfileV3SettingsSheetView(viewModel: .preview(), entry: .residence)
}
#endif
