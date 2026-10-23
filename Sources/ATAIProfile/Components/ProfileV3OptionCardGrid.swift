import ATUIKit
import SwiftUI

struct ProfileV3OptionCardGrid: View {
    let options: [ProfileV3CardOption]
    let selection: Set<String>
    let onToggle: (String) -> Void

    var body: some View {
        Grid(horizontalSpacing: ProfileV3Theme.Space.s16, verticalSpacing: ProfileV3Theme.Space.s20) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(row) { option in
                        ProfileV3OptionCard(option: option, isSelected: selection.contains(option.id)) {
                            onToggle(option.id)
                        }
                    }
                    if row.count == 1 {
                        Color.clear.gridCellUnsizedAxes(.vertical)
                    }
                }
            }
        }
    }

    private var rows: [[ProfileV3CardOption]] {
        stride(from: 0, to: options.count, by: 2).map { start in
            Array(options[start..<min(start + 2, options.count)])
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
