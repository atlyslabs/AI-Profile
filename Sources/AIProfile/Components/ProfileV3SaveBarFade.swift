import ATUIKit
import SwiftUI

struct ProfileV3SaveBarFade: View {
    var body: some View {
        ProfileV3Theme.clearToWhiteFade
            .frame(height: ProfileV3Theme.Sizes.Save.barFadeHeight + ProfileV3Theme.Sizes.Save.buttonHeight)
            .background(alignment: .bottom) {
                Color(at: .pureWhite)
                    .ignoresSafeArea(edges: .bottom)
                    .frame(height: 0)
            }
            .allowsHitTesting(false)
    }
}
