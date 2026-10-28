import ATUIKit
import SwiftUI

struct ProfileV3DeleteReasonView: View {
    let screen: ProfileV3DeleteAccountReason
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    @State private var reason = ""
    @FocusState private var isEditing: Bool

    private var trimmedReason: String {
        reason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            ProfileV3FocusScroll(scrollComponent: .deleteReason) {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        VStack(spacing: ProfileV3Theme.Sizes.Confirmation.textSpacing) {
                            if !screen.title.isEmpty {
                                Text(screen.title)
                                    .typoGraphy(.H6InterMedium18)
                                    .foregroundStyle(Color(at: .pureBlack))
                                    .frame(maxWidth: ProfileV3Theme.Sizes.Confirmation.titleWidth)
                            }
                            if !screen.subtitle.isEmpty {
                                Text(screen.subtitle)
                                    .typoGraphy(.B2InterMedium12)
                                    .foregroundStyle(Color(at: .neutralGrey400))
                                    .frame(maxWidth: ProfileV3Theme.Sizes.Confirmation.bodyWidth)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, ProfileV3Theme.Sizes.deleteReasonTitleTop)
                        HStack {
                            ProfileV3CircleIconButton.back(action: onBack)
                            Spacer()
                        }
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .padding(.top, ProfileV3Theme.Sizes.sheetHeaderTop)
                    }
                    reasonField
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .padding(.top, ProfileV3Theme.Sizes.deleteReasonFieldTop)
                }
            }
        }
        .background(Color(at: .pureWhite))
        .safeAreaInset(edge: .bottom) {
            if !screen.submitLabel.isEmpty {
                ProfileV3ContinueButton(
                    title: screen.submitLabel,
                    icon: ATIcon.SwiftUIImage.deleteOutline,
                    tint: ProfileV3Theme.Palette.destructive,
                    disabledTint: ProfileV3Theme.Palette.disabledText,
                    isEnabled: !trimmedReason.isEmpty
                ) {
                    onSubmit(trimmedReason)
                }
                .profileV3CTABar(bottom: ProfileV3Theme.Sizes.deleteReasonCTABottom)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.searchFocusDelayMilliseconds))
            guard !Task.isCancelled else { return }
            isEditing = true
        }
    }

    private var reasonField: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(
                cornerRadius: ProfileV3Theme.Radius.xs,
                style: .continuous
            )
            .stroke(
                ProfileV3Theme.Palette.reasonBorder,
                style: StrokeStyle(
                    lineWidth: ProfileV3Theme.Stroke.hairline,
                    dash: ProfileV3Theme.Sizes.deleteReasonDash
                )
            )
            if reason.isEmpty, !screen.placeholder.isEmpty {
                Text(screen.placeholder)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(ProfileV3Theme.Palette.reasonPlaceholder)
                    .padding(ProfileV3Theme.Sizes.deleteReasonFieldPadding)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $reason)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .scrollContentBackground(.hidden)
                .focused($isEditing)
                .padding(ProfileV3Theme.Sizes.deleteReasonEditorInset)
        }
        .frame(height: ProfileV3Theme.Sizes.deleteReasonFieldHeight)
    }
}

#if DEBUG
#Preview("Delete reason") {
    ProfileV3DeleteReasonView(screen: ProfileV3Fixtures.deleteAccountReason, onBack: {}, onSubmit: { _ in })
}
#endif
