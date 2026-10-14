import ATUIKit
import SwiftUI

struct ProfileV3AirportPickupView: View {
    @ObservedObject var viewModel: ProfileV3AirportPickupViewModel

    @State private var scrollOffset: CGFloat = 0

    private typealias Pickup = ProfileV3Theme.Sizes.Pickup
    private typealias Staged = ProfileV3Theme.Sizes.Staged

    private static let contentID = "pickup"

    private var cars: ProfileV3CarField { viewModel.cars }
    private var isStaged: Bool { viewModel.isStaged }
    private var isConfirming: Bool { viewModel.isConfirming }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    content
                        .id(Self.contentID)
                        .profileV3ScrollOffsetAnchor($scrollOffset)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDisabled(isConfirming)
                .profileV3ScrollOffset($scrollOffset)
                .onChange(of: isConfirming) { _, confirming in
                    guard confirming else { return }
                    withAnimation(ProfileV3Theme.Motion.expand) { proxy.scrollTo(Self.contentID, anchor: .top) }
                }
            }
            headerBackdrop
            topFade
            ProfileV3AgentSheetHeader(tag: viewModel.agentTag, avatarURL: viewModel.avatarURL, onBack: viewModel.tapBack)
            stagedCopy
                .opacity(isStaged ? 1 : 0)
                .animation(
                    isStaged ? ProfileV3Theme.Motion.stagedCopy : ProfileV3Theme.Motion.launchFade,
                    value: isStaged
                )
                .allowsHitTesting(false)
        }
        .background(Color(at: .pureWhite))
        .sensoryFeedback(.impact(weight: .light), trigger: cars.selection)
        .sensoryFeedback(.success, trigger: isStaged) { _, staged in staged }
        .onAppear(perform: viewModel.start)
        .onDisappear(perform: viewModel.cancelPendingWork)
    }

    private var content: some View {
        VStack(spacing: 0) {
            intro
                .opacity(isConfirming ? 0 : 1)
                .animation(ProfileV3Theme.Motion.launchFade, value: isConfirming)
            stage
            footer
                .opacity(isConfirming ? 0 : 1)
                .animation(ProfileV3Theme.Motion.launchFade, value: isConfirming)
        }
        .padding(.top, ProfileV3AgentSheetHeader.height(showsOrb: true))
        .padding(.bottom, ProfileV3Theme.Space.s24)
    }

    private var headerBackdrop: some View {
        VStack(spacing: 0) {
            Color(at: .pureWhite)
                .frame(height: ProfileV3AgentSheetHeader.height(showsOrb: true))
            ProfileV3Theme.whiteToClearFade
                .frame(height: ProfileV3Theme.Space.s24)
        }
        .opacity(min(max(scrollOffset / ProfileV3Theme.Space.s24, 0), 1))
        .allowsHitTesting(false)
    }

    private var intro: some View {
        VStack(spacing: ProfileV3Theme.Space.s12) {
            Text(viewModel.title)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.top, ProfileV3Theme.Sizes.Agent.summaryTop)
            Text(viewModel.subtitle)
                .frame(maxWidth: ProfileV3Theme.Sizes.Agent.summaryWidth)
            Text(viewModel.note)
                .padding(.top, ProfileV3Theme.Space.s8)
        }
        .typoGraphy(.B2InterSemibold12)
        .foregroundStyle(Color(at: .neutralGrey400))
        .multilineTextAlignment(.center)
    }

    private var stage: some View {
        ZStack {
            rings
                .opacity(isConfirming ? 0 : 1)
                .animation(ProfileV3Theme.Motion.launchFade, value: isConfirming)
            tracks
            carousel
        }
        .frame(height: Pickup.stageHeight)
        .padding(.top, ProfileV3Theme.Space.s20)
    }

    private var rings: some View {
        ZStack {
            Circle()
                .stroke(ProfileV3Theme.Palette.cardBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
                .frame(width: Pickup.ringOuter, height: Pickup.ringOuter)
            Circle()
                .stroke(Color(at: .neutralGrey100), lineWidth: ProfileV3Theme.Stroke.hairline)
                .frame(width: Pickup.ring, height: Pickup.ring)
        }
    }

    private var tracks: some View {
        HStack(spacing: Staged.trackSpacing) {
            track
            track
        }
        .frame(height: isStaged ? Staged.carTravel : 0, alignment: .bottom)
        .clipped()
        .mask { ProfileV3Theme.tyreTrackFade }
        .opacity(ProfileV3Theme.Opacity.stagedTrack)
        .frame(height: Staged.trackOrigin, alignment: .bottom)
        .frame(maxHeight: .infinity, alignment: .top)
        .animation(ProfileV3Theme.Motion.launch, value: isStaged)
        .allowsHitTesting(false)
    }

    private var track: some View {
        ProfileV3RemoteImage(url: ProfileV3AgentArt.tyreTracks.url, placeholder: .clear)
            .frame(width: Staged.trackImage, height: Staged.trackImage)
            .rotationEffect(.degrees(ProfileV3Theme.Rotation.diagonalBack))
            .offset(x: Staged.trackImageOffset.width, y: Staged.trackImageOffset.height)
            .scaleEffect(x: Staged.trackSqueeze, y: 1)
            .frame(width: Staged.trackWidth, height: Staged.carTravel)
            .clipped()
    }

    private var carousel: some View {
        ProfileV3CentredCarousel(
            itemWidth: Pickup.sideWidth,
            height: Pickup.height,
            spacing: Pickup.spacing,
            selection: selectedCarID,
            isScrollDisabled: isConfirming
        ) {
            ForEach(cars.options) { car in
                let isSelected = car.id == cars.selection
                Button {
                    viewModel.select(car.id)
                } label: {
                    carImage(car)
                        .frame(width: Pickup.sideWidth, height: Pickup.height)
                        .scaleEffect(isSelected ? 1 : Pickup.sideScale)
                        .opacity(isSelected ? 1 : ProfileV3Theme.Opacity.carSide)
                        .animation(ProfileV3Theme.Motion.selection, value: isSelected)
                        .opacity(isConfirming && !isSelected ? 0 : 1)
                        .animation(ProfileV3Theme.Motion.launchFade, value: isConfirming)
                        .offset(y: isStaged && isSelected ? -Staged.carTravel : 0)
                        .animation(ProfileV3Theme.Motion.launch, value: isStaged)
                }
                .buttonStyle(.plain)
                .disabled(isConfirming)
                .accessibilityLabel(car.name)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
    }

    private var selectedCarID: Binding<String?> {
        Binding(
            get: { cars.selection },
            set: { if let id = $0 { viewModel.select(id) } }
        )
    }

    @ViewBuilder
    private func carImage(_ car: ProfileV3CarOption) -> some View {
        if let url = viewModel.stageImageURL(for: car) {
            ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
        }
    }

    private var topFade: some View {
        VStack(spacing: 0) {
            Color(at: .pureWhite)
                .frame(height: Staged.fadeSolidHeight)
            ProfileV3Theme.whiteToClearFade
                .frame(height: Staged.fadeGradientHeight)
        }
        .opacity(isConfirming ? 1 : 0)
        .animation(ProfileV3Theme.Motion.launchFade, value: isConfirming)
        .allowsHitTesting(false)
    }

    private var footer: some View {
        VStack(spacing: 0) {
            if let car = cars.selectedCar {
                let brand = viewModel.brand(for: car)
                if let brand {
                    Text(brand)
                        .typoGraphy(.T1InterBold11)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .padding(.top, Pickup.nameTop)
                        .contentTransition(.opacity)
                }
                Text(car.name)
                    .font(Font.Denton.get(size: ProfileV3Theme.Typography.carNameSize, weight: .bold))
                    .foregroundStyle(Color(at: .pureBlack))
                    .padding(.top, brand == nil ? Pickup.nameTop : ProfileV3Theme.Space.s6)
                    .contentTransition(.opacity)
                if let spec = viewModel.spec(for: car) {
                    Text(spec)
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .padding(.top, ProfileV3Theme.Space.s6)
                        .contentTransition(.opacity)
                }
            }
            if !viewModel.autoLaunches {
                ProfileV3GradientButton(title: ProfileV3Strings.selectMyCar, action: viewModel.confirm)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, Pickup.buttonTop)
                    .disabled(isConfirming || !viewModel.isEligible)
            }
            Text(viewModel.footer)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(Color(at: .neutralGrey400))
                .multilineTextAlignment(.center)
                .frame(maxWidth: Pickup.captionWidth)
                .padding(.top, Pickup.captionTop)
        }
    }

    private var stagedCopy: some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            Text(ProfileV3Strings.rideStaged)
                .foregroundStyle(ProfileV3Theme.Palette.stagedTitle)
            Text(ProfileV3Strings.carLocked(cars.selectedCar?.name ?? ""))
                .foregroundStyle(Color(at: .pureBlack))
                .frame(maxWidth: Staged.titleWidth)
        }
        .typoGraphy(.H5InterMedium20)
        .multilineTextAlignment(.center)
        .padding(.top, Staged.titleTop)
    }
}

#if DEBUG
#Preview("Airport pickup · auto launch") {
    ProfileV3AirportPickupView(viewModel: .preview(autoLaunches: true))
}

#Preview("Airport pickup · select") {
    ProfileV3AirportPickupView(viewModel: .preview())
}

#Preview("Airport pickup · confirming") {
    ProfileV3AirportPickupView(viewModel: .preview(isConfirming: true))
}

#Preview("Airport pickup · launched") {
    ProfileV3AirportPickupView(viewModel: .preview(isConfirming: true, isStaged: true))
}
#endif
