import ATUIKit
import SwiftUI

struct ProfileV3CloseBar: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            ProfileV3CircleIconButton.close(size: ProfileV3Theme.Sizes.navButton, action: action)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.topBarInset)
        .padding(.top, ProfileV3Theme.Sizes.topBarTop)
    }
}

#if DEBUG
#Preview("Close bar") {
    VStack {
        ProfileV3CloseBar {}
        Spacer()
    }
    .background(Color(at: .pureWhite))
}
#endif
