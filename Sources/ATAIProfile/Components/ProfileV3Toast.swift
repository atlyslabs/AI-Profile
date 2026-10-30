import ATUIKit
import SwiftUI

struct ProfileV3Toast: View {
    let message: String
    var isError = false

    private var accent: Color {
        isError ? ProfileV3Theme.Palette.destructive : ProfileV3Theme.Palette.toastEnd
    }

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s12) {
            Text(message)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(
                    isError ? AnyShapeStyle(Color(at: .neutralGrey800)) : AnyShapeStyle(ProfileV3Theme.toastTextGradient)
                )
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
            badge
        }
        .padding(.horizontal, ProfileV3Theme.Space.s30)
        .frame(height: ProfileV3Theme.Control.large)
        .frame(maxWidth: .infinity)
        .background(toastBackground)
        .clipShape(Capsule())
        .shadow(
            color: ProfileV3Theme.Palette.shadow,
            radius: ProfileV3Theme.Shadow.cardRadius,
            y: ProfileV3Theme.Shadow.cardY
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .onAppear(perform: announce)
        .onChange(of: message) { _, _ in announce() }
    }

    private func announce() {
        AccessibilityNotification.Announcement(message).post()
    }

    private var toastBackground: some View {
        ZStack {
            Color(at: .pureWhite)
            RadialGradient(
                colors: [accent.opacity(ProfileV3Theme.Opacity.toastWash), .clear],
                center: .trailing,
                startRadius: 0,
                endRadius: ProfileV3Theme.Sizes.toastGlowRadius
            )
        }
        .allowsHitTesting(false)
    }

    private var badge: some View {
        ZStack {
            Circle()
                .fill(accent)
            (isError ? ATIcon.SwiftUIImage.priorityHigh : ATIcon.SwiftUIImage.check)
                .profileV3Icon(ProfileV3Theme.Icon.sm)
                .foregroundStyle(Color(at: .pureWhite))
        }
        .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
        .accessibilityHidden(true)
    }
}

extension View {
    func profileV3BottomToast(
        _ message: String?,
        isError: Bool,
        bottom: CGFloat = ProfileV3Theme.Sizes.Persona.toastBottom
    ) -> some View {
        overlay(alignment: .bottom) {
            if let message {
                ProfileV3Toast(message: message, isError: isError)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.bottom, bottom)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(ProfileV3Theme.Motion.expand, value: message)
    }
}

#if DEBUG
#Preview("Toast") {
    ProfileV3Toast(message: ProfileV3Strings.travellerDeleted("abhishek s."))
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
