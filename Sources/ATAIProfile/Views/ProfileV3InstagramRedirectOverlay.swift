import ATUIKit
import SwiftUI

struct ProfileV3InstagramRedirectOverlay: View {
    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .contentShape(Rectangle())
            ProfileV3FadeBand(solid: Layout.pageRedirectFadeSolid, fade: Layout.pageRedirectFade, edge: .bottom)
            ProfileV3Theme.instagramFollowWash
                .frame(height: Layout.followWashHeight)
                .offset(y: Layout.followWashHeight - Layout.pageRedirectWashVisible)
                .allowsHitTesting(false)
            VStack(spacing: 0) {
                ProfileV3AylOrbAssembly(size: Layout.redirectOrb)
                ProfileV3InstagramRedirectCopy(fillsLineBoxes: true)
                    .padding(.top, Layout.redirectLeadTop)
                Text(ProfileV3Strings.instagramRedirecting)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(ProfileV3Theme.instagramRedirectingGradient)
                    .padding(.vertical, TypographyStyle.B1InterSemibold14.lineSpacingAdjustment / 2)
                    .padding(.top, Layout.pageRedirectLabelTop)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, Layout.pageRedirectBottom)
            .accessibilityElement(children: .combine)
        }
        .ignoresSafeArea()
        .accessibilityAddTraits(.isModal)
    }
}

#if DEBUG
#Preview("Instagram redirect on App access") {
    ZStack {
        Color(at: .pureWhite)
        ProfileV3InstagramRedirectOverlay()
    }
}
#endif
