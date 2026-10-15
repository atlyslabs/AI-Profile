import SwiftUI

extension View {
    func profileV3CTABar(
        top: CGFloat = ProfileV3Theme.Sizes.pickerConfirmTop,
        bottom: CGFloat = ProfileV3Theme.Sizes.ctaBarBottom
    ) -> some View {
        padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, top)
            .padding(.bottom, bottom)
            .frame(maxWidth: .infinity)
            .background(ProfileV3Theme.clearToWhiteFade.ignoresSafeArea(edges: .bottom))
    }
}
