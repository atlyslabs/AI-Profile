import ATUIKit
import SwiftUI

struct ProfileV3AINoteLine: View {
    enum Icon {
        case sparkle
        case agent(URL?)
    }

    let icon: Icon
    private let attributed: AttributedString

    init(text: String, icon: Icon = .sparkle) {
        self.icon = icon
        self.attributed = (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            iconView
            Text(attributed)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(ProfileV3Theme.tagGradient)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var spacing: CGFloat {
        switch icon {
        case .sparkle: return ProfileV3Theme.Space.s12
        case .agent: return ProfileV3Theme.Space.s12
        }
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .sparkle:
            ProfileV3Vector.sparkle.image
                .profileV3Icon(ProfileV3Theme.Icon.xs)
                .foregroundStyle(Color(at: .neutralGrey600))
                .padding(.top, ProfileV3Theme.Space.s4)
        case .agent(let url):
            ProfileV3RemoteImage(url: url, placeholder: Color(at: .neutralGrey200))
                .frame(width: ProfileV3Theme.Icon.md, height: ProfileV3Theme.Icon.md)
            .clipShape(Circle())
            .background(Circle().fill(Color(at: .pureWhite)))
            .shadow(
                color: ProfileV3Theme.Palette.shadow,
                radius: ProfileV3Theme.Shadow.chipRadius,
                y: ProfileV3Theme.Shadow.chipY
            )
        }
    }
}

#if DEBUG
#Preview("AI note lines") {
    VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s20) {
        ProfileV3AINoteLine(text: "...I will scan flights 24x7 and get you the best deals")
        ProfileV3AINoteLine(text: "...I will look for cheapest flights **with a maximum of 1 stop**")
        ProfileV3AINoteLine(
            text: "...I will scan flights 24x7 and get you the best deals",
            icon: .agent(ProfileV3PlaceholderArt.agentFlight.url)
        )
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
