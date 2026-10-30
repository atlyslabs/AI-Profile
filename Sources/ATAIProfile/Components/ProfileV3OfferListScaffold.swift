import ATUIKit
import SwiftUI

struct ProfileV3OfferListScaffold<Header: View, Rows: View, Overlay: View>: View {
    let phase: ProfileV3LoadPhase
    let isLoadingMore: Bool
    let isScrollDisabled: Bool
    let onRetry: (() -> Void)?
    let onClose: () -> Void
    @ViewBuilder let header: () -> Header
    @ViewBuilder let rows: () -> Rows
    @ViewBuilder let overlay: () -> Overlay

    var body: some View {
        ZStack(alignment: .top) {
            ProfileV3FrostedBackdrop(tint: ProfileV3Theme.Palette.benefitsBackdrop)
            if phase != .loaded {
                ProfileV3LoadStateView(phase: phase) { onRetry?() }
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ProfileV3Vector.worldPassPlus.image
                            .profileV3Icon(ProfileV3Theme.Icon.xl)
                            .rotationEffect(.degrees(ProfileV3Theme.Rotation.quarter))
                            .foregroundStyle(ProfileV3Theme.Palette.filterChipSelected)
                        header()
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, ProfileV3Theme.Sizes.benefitsHeaderTop)
                    LazyVStack(spacing: ProfileV3Theme.Space.s20) {
                        rows()
                    }
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, ProfileV3Theme.Space.s32)
                    .padding(.bottom, ProfileV3Theme.Space.s24)
                    if isLoadingMore {
                        ProfileV3Spinner()
                            .padding(.bottom, ProfileV3Theme.Space.s24)
                            .transition(.opacity)
                    }
                }
                .animation(ProfileV3Theme.Motion.contentFade, value: isLoadingMore)
            }
            .opacity(phase == .loaded ? 1 : 0)
            .scrollDisabled(isScrollDisabled)
            ProfileV3CloseBar(action: onClose)
            overlay()
        }
        .coordinateSpace(.named(ProfileV3HeroSpace.name))
    }
}
