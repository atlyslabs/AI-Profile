import ATUIKit
import SwiftUI

struct ProfileV3RideRegionsView: View {
    @ObservedObject var viewModel: ProfileV3RideRegionsViewModel

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            if let content = viewModel.content {
                ProfileV3FadingScroll {
                    ProfileV3RideRegionsContent(content: content)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
                }
            } else {
                ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .profileV3Sheet(.fitted(fittedHeight), cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius)
        .onDisappear(perform: viewModel.cancel)
    }

    private var fittedHeight: CGFloat? {
        guard viewModel.content != nil, contentHeight > 0 else { return nil }
        return Self.headerHeight + contentHeight
    }

    private static var headerHeight: CGFloat {
        ProfileV3Theme.Sizes.Agent.backTop + ProfileV3Theme.Sizes.circleButton
    }

    private var header: some View {
        ProfileV3AgentSheetChrome(control: .back(viewModel.close), title: {
            if let title = viewModel.content?.title, !title.isEmpty {
                ProfileV3TagLabel(text: title)
            }
        })
        .frame(maxWidth: .infinity)
        .frame(height: Self.headerHeight, alignment: .top)
    }
}

struct ProfileV3RideRegionsContent: View {
    let content: ProfileV3RideRegions

    private typealias Regions = ProfileV3Theme.Sizes.RideRegions

    var body: some View {
        loaded(content)
    }

    private func loaded(_ content: ProfileV3RideRegions) -> some View {
        VStack(spacing: 0) {
            if !content.heading.isEmpty {
                Text(content.heading)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(width: Regions.headingWidth)
                    .padding(.top, Regions.headingTop)
            }
            if !content.dividerLabel.isEmpty {
                divider(content.dividerLabel)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, Regions.dividerTop)
            }
            VStack(spacing: Regions.cardSpacing) {
                ForEach(content.regions) { region in
                    card(region)
                }
            }
            .padding(.horizontal, Regions.cardInset)
            .padding(.top, Regions.cardsTop)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, Regions.bottom)
    }

    private func divider(_ label: String) -> some View {
        HStack(spacing: Regions.dividerSpacing) {
            ProfileV3DashedDivider()
            ProfileV3TagLabel(text: label)
                .opacity(ProfileV3Theme.Opacity.rideRegionsDivider)
                .fixedSize()
            ProfileV3DashedDivider()
        }
    }

    private func card(_ region: ProfileV3RideRegions.Region) -> some View {
        let shape = RoundedRectangle(cornerRadius: Regions.cardRadius, style: .continuous)
        return ProfileV3RemoteImage(url: region.imageURL, contentMode: .fill)
            .aspectRatio(region.aspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(shape)
            .profileV3Outlined(shape, border: ProfileV3Theme.Palette.rideRegionBorder)
            .accessibilityElement()
            .accessibilityLabel(region.name)
            .accessibilityAddTraits(.isImage)
    }
}

#if DEBUG
#Preview("Ride regions") {
    Color.black
        .sheet(isPresented: .constant(true)) {
            ProfileV3RideRegionsView(viewModel: {
                let viewModel = ProfileV3RideRegionsViewModel(repository: ProfileV3MockRepository(), onClose: {})
                viewModel.load()
                return viewModel
            }())
        }
}
#endif
