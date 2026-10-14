import ATUIKit
import SwiftUI

struct ProfileV3DeleteReasonView: View {
    var isSubmitting = false
    var errorMessage: String?
    let onBack: () -> Void
    var onReasonChange: () -> Void = {}
    let onSubmit: (String) -> Void

    @State private var reason = ""
    @FocusState private var isEditing: Bool

    private var trimmedReason: String {
        reason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            ProfileV3FocusScroll {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        VStack(spacing: ProfileV3Theme.Sizes.Confirmation.textSpacing) {
                            Text(ProfileV3Strings.deleteReasonTitle)
                                .typoGraphy(.H6InterMedium18)
                                .foregroundStyle(Color(at: .pureBlack))
                                .frame(maxWidth: ProfileV3Theme.Sizes.Confirmation.titleWidth)
                            Text(ProfileV3Strings.deleteReasonSubtitle)
                                .typoGraphy(.B2InterMedium12)
                                .foregroundStyle(Color(at: .neutralGrey400))
                                .frame(maxWidth: ProfileV3Theme.Sizes.Confirmation.bodyWidth)
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, ProfileV3Theme.Sizes.deleteReasonTitleTop)
                        HStack {
                            ProfileV3CircleIconButton.back(action: onBack)
                                .disabled(isSubmitting)
                            Spacer()
                        }
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .padding(.top, ProfileV3Theme.Sizes.sheetHeaderTop)
                    }
                    reasonField
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .padding(.top, ProfileV3Theme.Sizes.deleteReasonFieldTop)
                    if let errorMessage {
                        Text(errorMessage)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(ProfileV3Theme.Palette.error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                            .padding(.top, ProfileV3Theme.Sizes.fieldErrorSpacing)
                    }
                }
            }
        }
        .background(Color(at: .pureWhite))
        .sensoryFeedback(.error, trigger: errorMessage) { _, error in error != nil }
        .safeAreaInset(edge: .bottom) {
            ProfileV3ContinueButton(
                title: ProfileV3Strings.deleteAccount,
                icon: ATIcon.SwiftUIImage.deleteOutline,
                tint: ProfileV3Theme.Palette.destructive,
                disabledTint: ProfileV3Theme.Palette.disabledText,
                isLoading: isSubmitting,
                isEnabled: !trimmedReason.isEmpty
            ) {
                onSubmit(trimmedReason)
            }
            .profileV3CTABar(bottom: ProfileV3Theme.Sizes.deleteReasonCTABottom)
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
            if reason.isEmpty {
                Text(ProfileV3Strings.deleteReasonPlaceholder)
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
                .disabled(isSubmitting)
        }
        .frame(height: ProfileV3Theme.Sizes.deleteReasonFieldHeight)
        .onChange(of: reason) { _, _ in
            onReasonChange()
        }
    }
}

#if DEBUG
#Preview("Delete reason") {
    ProfileV3DeleteReasonView(onBack: {}, onSubmit: { _ in })
}

#Preview("Delete reason · submitting") {
    ProfileV3DeleteReasonView(isSubmitting: true, onBack: {}, onSubmit: { _ in })
}

#Preview("Delete reason · failed") {
    ProfileV3DeleteReasonView(errorMessage: ProfileV3Strings.deleteRequestFailed, onBack: {}, onSubmit: { _ in })
}
#endif
