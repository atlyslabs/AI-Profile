import ATUIKit
import SwiftUI

struct ProfileV3OptionCardGrid: View {
    let options: [ProfileV3CardOption]
    let selection: Set<String>
    let onToggle: (String) -> Void

    private static let columns = [
        GridItem(.flexible(), spacing: ProfileV3Theme.Space.s16),
        GridItem(.flexible(), spacing: ProfileV3Theme.Space.s16)
    ]

    var body: some View {
        LazyVGrid(columns: Self.columns, spacing: ProfileV3Theme.Space.s20) {
            ForEach(options) { option in
                ProfileV3OptionCard(option: option, isSelected: selection.contains(option.id)) {
                    onToggle(option.id)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Option card grid") {
    ProfileV3OptionCardGrid(
        options: [
            ProfileV3CardOption(id: "avml", code: "AVML", detail: "vegetarian (asian)"),
            ProfileV3CardOption(id: "vgml", code: "VGML", detail: "vegan, no animal products"),
            ProfileV3CardOption(id: "vjml", code: "VJML", detail: "jain-no root veggies"),
            ProfileV3CardOption(id: "moml", code: "MOML", detail: "halal/muslim meal")
        ],
        selection: ["avml"],
        onToggle: { _ in }
    )
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
