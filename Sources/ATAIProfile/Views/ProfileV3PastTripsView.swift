import ATUIKit
import SwiftUI

struct ProfileV3PastTripsView: View {
    @ObservedObject var viewModel: ProfileV3PastTripsViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasEntered = false
    @State private var playsEntranceSheen = true
    @State private var sheets = ProfileV3PastTripsSheetPresenter()

    private typealias Sizes = ProfileV3Theme.Sizes.PastTrips
    private typealias Motion = ProfileV3Theme.Motion

    var body: some View {
        ZStack {
            ProfileV3Theme.Palette.pastTripsBackground
                .ignoresSafeArea()
            page
                .blur(radius: viewModel.sheet == nil ? 0 : Sizes.backdropBlur)
                .allowsHitTesting(viewModel.sheet == nil)
                .accessibilityHidden(viewModel.sheet != nil)
        }
        .task { viewModel.start() }
        .onAppear { sheets.show(viewModel.sheet, for: viewModel) }
        .onChange(of: viewModel.sheet) { _, sheet in sheets.show(sheet, for: viewModel) }
        .onDisappear { sheets.dismiss() }
        .sensoryFeedback(.success, trigger: viewModel.completions)
        .sensoryFeedback(.error, trigger: viewModel.notice) { _, notice in notice != nil }
        .profileV3ErrorAlert(
            ProfileV3Strings.loadFailedTitle,
            message: viewModel.notice ?? "",
            isPresented: viewModel.notice != nil,
            retry: viewModel.canRetryNotice ? viewModel.retryAfterNotice : nil,
            onDismiss: viewModel.clearNotice
        )
    }

    private var page: some View {
        ZStack(alignment: .top) {
            content
            ProfileV3Theme.pastTripsBottomFade
                .frame(height: Sizes.bottomFade)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
            header
            fab
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .loading:
            ProgressView()
                .tint(Color(at: .pureWhite))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            failed
        case .loaded:
            if viewModel.trips.isEmpty {
                emptyState
                    .transition(.opacity)
            } else {
                list
            }
        }
    }

    private var list: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: Sizes.cardSpacing) {
                    ForEach(Array(viewModel.trips.enumerated()), id: \.element.id) { index, trip in
                        row(trip, index: index)
                            .id(trip.id)
                    }
                }
                .padding(.top, Sizes.listTop)
                .padding(.bottom, Sizes.listBottom)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: viewModel.focus) { _, focus in
                guard let focus else { return }
                let animation = reduceMotion ? nil : ProfileV3Theme.Motion.scrollReveal
                DispatchQueue.main.async {
                    withAnimation(animation) { proxy.scrollTo(focus.tripID, anchor: .center) }
                }
            }
        }
        .onAppear(perform: enter)
    }

    private func row(_ trip: ProfileV3PastTrip, index: Int) -> some View {
        let delay = Double(min(index, Sizes.entranceCount)) * Motion.pastTripsStaggerSeconds
        let playsSheen = playsEntranceSheen && index < Sizes.entranceCount
        return ProfileV3PastTripCard(
            trip: trip,
            reveals: viewModel.revealingTripID == trip.id,
            sheenDelay: playsSheen ? Motion.pastTripsSheenDelaySeconds + delay : nil,
            onRevealEnd: { viewModel.didFinishReveal(trip.id) }
        )
        .id(trip.revision)
        .overlay(alignment: .topTrailing) { moreButton(trip) }
        .zIndex(viewModel.revealingTripID == trip.id ? -1 : 0)
        .opacity(hasEntered ? 1 : 0)
        .offset(y: hasEntered || reduceMotion ? 0 : Sizes.entranceOffset)
        .animation(reduceMotion ? nil : Motion.pastTripsEntrance.delay(delay), value: hasEntered)
        .transition(
            .asymmetric(
                insertion: .opacity,
                removal: .opacity
                    .combined(with: .offset(y: Sizes.deleteLift))
                    .combined(with: .scale(scale: Sizes.deleteScale))
            )
        )
    }

    private func moreButton(_ trip: ProfileV3PastTrip) -> some View {
        Button { viewModel.tapMore(trip) } label: {
            ATIcon.SwiftUIImage.moreVert
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.tripMore))
                .frame(width: ProfileV3Theme.Control.tapTarget, height: ProfileV3Theme.Control.tapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .offset(x: Sizes.moreOffsetX, y: Sizes.moreOffsetY)
        .accessibilityLabel(ProfileV3Strings.pastTripOptions(trip.countryName))
    }

    private var header: some View {
        ProfileV3TopBar(onBack: viewModel.close, title: {
            Text(viewModel.title)
                .typoGraphy(.H4DentonMedium24)
                .foregroundStyle(Color(at: .pureWhite))
                .accessibilityAddTraits(.isHeader)
        })
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            LinearGradient(
                colors: [
                    ProfileV3Theme.Palette.pastTripsBackground,
                    ProfileV3Theme.Palette.pastTripsBackground.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Sizes.headerFade)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
        }
    }

    private var fab: some View {
        let isShown = viewModel.phase == .loaded
        return Button(action: viewModel.tapAdd) {
            ATIcon.SwiftUIImage.close
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .rotationEffect(Sizes.fabIconRotation)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(width: Sizes.fab, height: Sizes.fab)
                .background(Circle().fill(Color(at: .pureWhite)))
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .accessibilityLabel(ProfileV3Strings.addPastTrip)
        .padding(.leading, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.bottom, Sizes.fabBottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .opacity(isShown ? 1 : 0)
        .allowsHitTesting(isShown)
        .accessibilityHidden(!isShown)
        .animation(Motion.contentFade, value: viewModel.phase)
    }

    private var emptyState: some View {
        VStack(spacing: ProfileV3Theme.Space.s12) {
            Text(ProfileV3Strings.noPastTripsTitle)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(Color(at: .pureWhite))
            Text(ProfileV3Strings.noPastTripsBody)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.tripMonth))
                .frame(width: Sizes.emptyTextWidth)
        }
        .multilineTextAlignment(.center)
        .padding(.top, Sizes.emptyTop)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .combine)
    }

    private var failed: some View {
        VStack(spacing: ProfileV3Theme.Space.s16) {
            Text(ProfileV3Strings.loadFailed)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.tripMonth))
                .multilineTextAlignment(.center)
            ProfileV3PillButton(title: ProfileV3Strings.retry, size: .medium, action: viewModel.load)
        }
        .padding(.top, Sizes.emptyTop)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func enter() {
        guard !hasEntered else { return }
        hasEntered = true
        guard !reduceMotion else {
            playsEntranceSheen = false
            return
        }
        Task {
            try? await Task.sleep(for: .seconds(Motion.pastTripsEntranceWindowSeconds))
            playsEntranceSheen = false
        }
    }
}

struct ProfileV3PastTripDeleteSheet: View {
    @ObservedObject var viewModel: ProfileV3PastTripsViewModel

    var body: some View {
        ProfileV3ConfirmationView.deletePastTrip(
            viewModel.deleteConfirm,
            isDeleting: viewModel.isDeleting,
            onBack: viewModel.cancelDelete,
            onConfirm: viewModel.confirmDelete
        )
    }
}

#if DEBUG
#Preview("Past trips") {
    ProfileV3PastTripsView(
        viewModel: ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: ProfileV3MockRepository(delay: .milliseconds(200)),
            startsAdding: false,
            onChange: {},
            onClose: {}
        )
    )
}

#Preview("Past trips · adding") {
    ProfileV3PastTripsView(
        viewModel: ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.coTravellerPass,
            repository: ProfileV3MockRepository(delay: .milliseconds(200)),
            startsAdding: true,
            onChange: {},
            onClose: {}
        )
    )
}
#endif
