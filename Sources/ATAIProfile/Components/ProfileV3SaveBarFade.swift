import ATUIKit
import SwiftUI

struct ProfileV3SaveBarFade: View {
    var body: some View {
        ProfileV3FadeBand(fade: ProfileV3Theme.Sizes.Save.barFadeHeight + ProfileV3Theme.Sizes.Save.buttonHeight, edge: .bottom)
            .background(alignment: .bottom) {
                Color(at: .pureWhite)
                    .ignoresSafeArea(edges: .bottom)
                    .frame(height: 0)
            }
            .allowsHitTesting(false)
    }
}
