import ATUIKit
import SwiftUI

struct ProfileV3EditTravellersView: View {
    let travellers: [ProfileV3TravellerRow]
    var phase: ProfileV3LoadPhase = .loaded
    var toast: String?
    let onBack: () -> Void
    let onClose: () -> Void
    var onRetry: () -> Void = {}
    let onSelect: (ProfileV3TravellerRow) -> Void
    let onAdd: () -> Void

    @State private var listHeight: CGFloat = 0
    @State private var headerPin = ProfileV3HeaderPin()

    private static let listID = "travellers"

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.edit,
                title: ProfileV3Strings.editTravellers,
                onBack: onBack,
                onClose: onClose
            )
            .padding(.bottom, ProfileV3Theme.Sizes.Traveller.listHeaderGap)
            if phase == .loaded {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        list
                            .id(Self.listID)
                            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                                listHeight = $0
                            }
                            .profileV3ScrollOffsetAnchor(headerOffset)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .profileV3ScrollOffset(headerOffset)
                    .frame(maxHeight: listHeight > 0 ? listHeight : nil)
                    .overlay(alignment: .top) { ProfileV3EditTravellersHeaderFade(pin: headerPin) }
                    .onChange(of: listHeight) { revealToast(proxy) }
                    .onChange(of: toast) { revealToast(proxy) }
                }
            } else {
                ProfileV3LoadStateView(phase: phase, retry: onRetry)
                    .frame(height: ProfileV3Theme.Sizes.settingsLoadStateHeight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { addBar }
    }

    private var headerOffset: Binding<CGFloat> {
        Binding(get: { headerPin.offset }, set: { headerPin.offset = $0 })
    }

    private func revealToast(_ proxy: ScrollViewProxy) {
        guard toast != nil else { return }
        withAnimation(ProfileV3Theme.Motion.expand) { proxy.scrollTo(Self.listID, anchor: .bottom) }
    }

    private var list: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Traveller.cardSpacing) {
            ForEach(travellers) { traveller in
                ProfileV3TravellerCard(traveller: traveller) { onSelect(traveller) }
            }
            if let toast {
                ProfileV3Toast(message: toast)
                    .profileV3FeedbackOnAppear(.success)
                    .padding(.top, ProfileV3Theme.Space.s14)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.Traveller.listTop)
        .padding(.bottom, ProfileV3Theme.Sizes.settingsSheetBottom)
        .animation(ProfileV3Theme.Motion.expand, value: toast)
    }

    private var addBar: some View {
        ProfileV3ContinueButton(title: ProfileV3Strings.addTravellerPill, action: onAdd)
            .profileV3CTABar()
    }
}

private struct ProfileV3EditTravellersHeaderFade: View {
    let pin: ProfileV3HeaderPin

    var body: some View {
        ProfileV3Theme.whiteToClearFade
            .frame(height: ProfileV3Theme.Sizes.SettingsPage.headerFade)
            .opacity(pin.progress)
            .allowsHitTesting(false)
    }
}

#if DEBUG
#Preview("Edit travellers") {
    ProfileV3EditTravellersView(
        travellers: ProfileV3Fixtures.editTravellers.travellers,
        onBack: {},
        onClose: {},
        onSelect: { _ in },
        onAdd: {}
    )
}

#Preview("Edit travellers · loading") {
    ProfileV3EditTravellersView(
        travellers: [],
        phase: .loading,
        onBack: {},
        onClose: {},
        onSelect: { _ in },
        onAdd: {}
    )
}

#Preview("Edit travellers · failed") {
    ProfileV3EditTravellersView(
        travellers: [],
        phase: .failed,
        onBack: {},
        onClose: {},
        onSelect: { _ in },
        onAdd: {}
    )
}

#Preview("Edit travellers · empty") {
    ProfileV3EditTravellersView(
        travellers: [],
        onBack: {},
        onClose: {},
        onSelect: { _ in },
        onAdd: {}
    )
}

#Preview("Edit travellers · deleted") {
    ProfileV3EditTravellersView(
        travellers: Array(ProfileV3Fixtures.editTravellers.travellers.prefix(1)),
        toast: ProfileV3Strings.travellerDeleted("abhishek s."),
        onBack: {},
        onClose: {},
        onSelect: { _ in },
        onAdd: {}
    )
}
#endif
