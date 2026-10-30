import ATUIKit
import SwiftUI

struct ProfileV3KYCRedirectOverlay<Centre: View>: View {
    let message: String
    let centreToCopy: CGFloat
    var copyToStatus: CGFloat = ProfileV3Theme.Sizes.AddProgramme.kycCopyToStatus
    let bottomSpace: CGFloat
    var status: String = ProfileV3Strings.redirectingToKYC
    @ViewBuilder var centre: Centre

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            centre
                .background(glow)
                .padding(.bottom, centreToCopy)
            Text(message)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: ProfileV3Theme.Sizes.AddProgramme.kycCopyWidth)
            if !status.isEmpty {
                ProfileV3GradientStatusText(text: status)
                    .padding(.top, copyToStatus)
            }
            Spacer(minLength: 0)
                .frame(height: bottomSpace)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var glow: some View {
        ProfileV3RainbowGlow(
            diameter: ProfileV3Theme.Sizes.AddProgramme.glow,
            gradient: ProfileV3Theme.kycOverlayGlowGradient
        )
        .opacity(ProfileV3Theme.Motion.kycOverlayGlowOpacity)
    }
}

#if DEBUG
#Preview("KYC redirect overlay") {
    ProfileV3KYCRedirectOverlay(
        message: ProfileV3Strings.addProgrammeKYCRequired,
        centreToCopy: ProfileV3Theme.Sizes.AddProgramme.kycOrbToCopy,
        bottomSpace: ProfileV3Theme.Sizes.AddProgramme.kycBottom
    ) {
        ProfileV3AtlysOrb(ring: .scanning)
    }
    .background(Color(at: .pureWhite))
}
#endif
