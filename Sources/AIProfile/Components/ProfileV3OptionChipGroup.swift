import ATUIKit
import SwiftUI

struct ProfileV3OptionChipGroup: View {
    let options: [ProfileV3ChipOption]
    let selection: Set<String>
    var onAdd: (() -> Void)?
    let onToggle: (String) -> Void

    var body: some View {
        ProfileV3FlowLayout {
            ForEach(options) { option in
                ProfileV3Chip(
                    title: option.title,
                    isSelected: selection.contains(option.id),
                    leadingImageURL: option.logoURL,
                    action: { onToggle(option.id) }
                )
            }
            if let onAdd {
                ProfileV3Chip(title: ProfileV3Strings.addChip, isSelected: false, action: onAdd)
            }
        }
    }
}

#if DEBUG
#Preview("Option chips") {
    ProfileV3OptionChipGroup(
        options: Array(ProfileV3AgentFixtures.airlines.prefix(3)),
        selection: ["singapore-airlines"],
        onAdd: {},
        onToggle: { _ in }
    )
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
