import ATUIKit
import SwiftUI

struct ProfileV3RideRegionsView: View {
    @ObservedObject var viewModel: ProfileV3RideRegionsViewModel

    @State private var measured = Measured()
    @State private var headerPin = ProfileV3HeaderPin()

    private struct Measured: Equatable {
        var content: CGFloat = 0
        var bottomInset: CGFloat = 0
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if let content = viewModel.content {
                ScrollView(showsIndicators: false) {
                    ProfileV3RideRegionsContent(content: content)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measured.content = $0 }
                        .profileV3HeaderFadeAnchor(headerPin)
                }
                .profileV3HeaderFade(headerPin)
                .scrollBounceBehavior(.basedOnSize)
            } else {
                ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { measured.bottomInset = $0 }
        .profileV3FittedDetent(fittedHeight)
        .onDisappear(perform: viewModel.cancel)
    }

    private var fittedHeight: CGFloat? {
        guard viewModel.content != nil, measured.content > 0 else { return nil }
        return Self.headerHeight + measured.content + measured.bottomInset
    }

    private static var headerHeight: CGFloat {
        ProfileV3Theme.Sizes.Agent.backTop + ProfileV3Theme.Sizes.circleButton
    }

    private var header: some View {
        ZStack(alignment: .top) {
            ProfileV3SheetGrabber(
                width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                color: Color(at: .neutralGrey200),
                top: ProfileV3Theme.Space.s10
            )
            ZStack {
                if let title = viewModel.content?.title, !title.isEmpty {
                    ProfileV3TagLabel(text: title)
                }
                HStack {
                    ProfileV3CircleIconButton.back(action: viewModel.close)
                    Spacer()
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
        }
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
            .overlay {
                shape.strokeBorder(ProfileV3Theme.Palette.rideRegionBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
            }
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
            .presentationCornerRadius(ProfileV3Theme.Sizes.Agent.sheetCornerRadius)
            .presentationDragIndicator(.hidden)
        }
}
#endif
