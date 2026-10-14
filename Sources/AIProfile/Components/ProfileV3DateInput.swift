import ATUIKit
import SwiftUI

struct ProfileV3DateInput: View {
    let placeholder: String
    var accessibilityLabel: String?
    let date: Date?
    let onChange: @MainActor (Date) -> Void

    @State private var isPicking = false

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            Button(action: togglePicker) {
                Text(formatted ?? placeholder.lowercased())
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(date == nil ? ProfileV3Theme.Palette.placeholderText : Color(at: .pureBlack))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .profileV3UnderlinedFieldStyle(
                        isFocused: isPicking,
                        width: ProfileV3Theme.Sizes.underlinedFieldWidth
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel ?? placeholder)
            .accessibilityValue(formatted ?? "")
            if isPicking {
                DatePicker(
                    accessibilityLabel ?? placeholder,
                    selection: Binding(get: { date ?? Self.today }, set: onChange),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .transition(.opacity)
            }
        }
    }

    private var formatted: String? {
        date?.formatted(.dateTime.day().month(.abbreviated).year())
    }

    private static var today: Date { Calendar.current.startOfDay(for: .now) }

    private func togglePicker() {
        if !isPicking, date == nil {
            onChange(Self.today)
        }
        withAnimation(ProfileV3Theme.Motion.selection) { isPicking.toggle() }
    }
}

#if DEBUG
private struct ProfileV3DateInputPreview: View {
    @State private var date: Date?

    var body: some View {
        ProfileV3DateInput(placeholder: "BIRTHDAY", date: date) { date = $0 }
            .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
            .background(Color(at: .pureWhite))
    }
}

#Preview("Date input") {
    ProfileV3DateInputPreview()
}
#endif
