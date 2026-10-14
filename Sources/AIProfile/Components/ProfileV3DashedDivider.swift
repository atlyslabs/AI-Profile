import ATUIKit
import SwiftUI

struct ProfileV3DashedDivider: View {
    var body: some View {
        Color.clear
            .frame(height: ProfileV3Theme.Stroke.hairline)
            .atFormFieldBottomLine(isError: false, isFocused: false, style: .dashed, tintsOnFocus: false)
    }
}

#if DEBUG
#Preview("Dashed divider") {
    ProfileV3DashedDivider()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
