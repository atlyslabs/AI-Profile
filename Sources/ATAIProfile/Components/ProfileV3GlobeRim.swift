import ATUIKit
import SwiftUI

struct ProfileV3GlobeRim: View {
    private typealias Globe = ProfileV3Theme.Globe

    var body: some View {
        if ProfileV3FeatureFlags.isGlobeRimEnabled {
            rim
        }
    }

    private var rim: some View {
        ZStack {
            Circle()
                .strokeBorder(Globe.rimGradient, lineWidth: Globe.rimGlowWidth)
                .padding(-Globe.rimGlowWidth)
                .blur(radius: Globe.rimGlowBlur)
                .opacity(Globe.rimGlowOpacity)
            Circle()
                .strokeBorder(Globe.rimGradient, lineWidth: Globe.rimWidth)
                .padding(-Globe.rimWidth)
        }
        .mask {
            Rectangle()
                .padding(-Globe.rimMaskOutset)
                .overlay {
                    Circle()
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Globe rim") {
    ProfileV3GlobeRim()
        .frame(width: 140, height: 140)
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureBlack))
}
#endif
