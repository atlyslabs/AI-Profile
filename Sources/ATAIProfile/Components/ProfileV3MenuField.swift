import SwiftUI

struct ProfileV3MenuField: View {
    struct Option: Identifiable, Equatable {
        let value: String
        let label: String

        var id: String { value }
    }

    let options: [Option]
    @Binding var selection: String
    let accessibilityLabel: String

    private var selectedLabel: String? {
        options.first { $0.value == selection }?.label
    }

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    selection = option.value
                } label: {
                    if option.value == selection {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Text(option.label)
                    }
                }
            }
        } label: {
            ProfileV3PickerFieldRow(value: selectedLabel)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(selectedLabel ?? "")
    }
}

#if DEBUG
private struct ProfileV3MenuFieldPreview: View {
    @State private var tier = ""

    var body: some View {
        ProfileV3MenuField(
            options: ["Silver", "Gold", "Platinum"].map { ProfileV3MenuField.Option(value: $0, label: $0) },
            selection: $tier,
            accessibilityLabel: "Tier"
        )
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
}

#Preview("Menu field") {
    ProfileV3MenuFieldPreview()
}
#endif
