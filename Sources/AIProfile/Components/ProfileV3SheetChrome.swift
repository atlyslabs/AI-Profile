import ATUIKit
import SwiftUI

struct ProfileV3SheetGrabber: View {
    var width: CGFloat = ProfileV3Theme.Sizes.sheetGrabberWidth
    var color = Color(at: .neutralGrey300)
    var top: CGFloat = ProfileV3Theme.Sizes.sheetGrabberTop

    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: ProfileV3Theme.Sizes.sheetGrabberHeight)
            .padding(.top, top)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

private struct ProfileV3SheetHeaderIcon: View {
    let image: Image

    var body: some View {
        image
            .profileV3Icon(ProfileV3Theme.Sizes.sheetHeaderIcon)
            .foregroundStyle(Color(at: .pureBlack))
    }
}

struct ProfileV3SheetChrome: View {
    var icon: Image?
    let title: String
    var onBack: (() -> Void)?
    var onClose: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            ZStack(alignment: .top) {
                VStack(spacing: ProfileV3Theme.Sizes.sheetHeaderIconSpacing) {
                    if let icon {
                        ProfileV3SheetHeaderIcon(image: icon)
                    }
                    ProfileV3TagLabel(text: title)
                }
                .padding(
                    .top,
                    icon == nil ? ProfileV3Theme.Sizes.sheetTitleOnlyTop : ProfileV3Theme.Sizes.sheetHeaderIconTop
                )
                HStack {
                    if let onBack {
                        ProfileV3CircleIconButton.back(action: onBack)
                    }
                    Spacer()
                    if let onClose {
                        ProfileV3CircleIconButton.close(action: onClose)
                    }
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, ProfileV3Theme.Sizes.sheetHeaderTop)
        }
    }
}

#if DEBUG
#Preview("Sheet chrome") {
    VStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3SheetChrome(icon: ATIcon.SwiftUIImage.settings, title: ProfileV3Strings.settings, onClose: {})
        ProfileV3SheetChrome(icon: ATIcon.SwiftUIImage.flag, title: ProfileV3Strings.countryOfResidence, onBack: {})
        ProfileV3SheetChrome(title: ProfileV3Strings.logout, onBack: {})
        ProfileV3SheetChrome(icon: ATIcon.SwiftUIImage.database, title: ProfileV3Strings.connectors, onBack: {})
    }
    .padding(.vertical, ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
