import ATUIKit
import SwiftUI

struct ProfileV3DateInput: View {
    let placeholder: String
    var accessibilityLabel: String?
    let date: Date?
    var hidesYear = false
    let onChange: @MainActor (Date) -> Void

    @State private var isPicking = false
    @State private var day = 1
    @State private var month = 1

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
                picker
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }
        }
        .onAppear { syncWheels(from: date) }
        .onChange(of: date) { _, newDate in syncWheels(from: newDate) }
    }

    @ViewBuilder
    private var picker: some View {
        if hidesYear {
            HStack(spacing: 0) {
                Picker(accessibilityLabel ?? placeholder, selection: dayBinding) {
                    ForEach(1...31, id: \.self) { Text("\($0)").tag($0) }
                }
                Picker(ProfileV3Strings.tripMonth, selection: monthBinding) {
                    ForEach(1...12, id: \.self) { Text(Self.monthName($0)).tag($0) }
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        } else {
            DatePicker(
                accessibilityLabel ?? placeholder,
                selection: Binding(get: { date ?? Self.today }, set: onChange),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
        }
    }

    private var dayBinding: Binding<Int> {
        Binding(get: { day }, set: { day = $0; commitDayMonth() })
    }

    private var monthBinding: Binding<Int> {
        Binding(get: { month }, set: { month = $0; commitDayMonth() })
    }

    private var formatted: String? {
        guard let date else { return nil }
        if hidesYear { return Self.dayMonthFormatter.string(from: date) }
        return date.formatted(.dateTime.day().month(.abbreviated).year())
    }

    private static var today: Date { Calendar.current.startOfDay(for: .now) }

    private static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    private static func monthName(_ month: Int) -> String {
        let symbols = dayMonthFormatter.shortMonthSymbols ?? []
        guard symbols.indices.contains(month - 1) else { return "" }
        return symbols[month - 1]
    }

    private func togglePicker() {
        if !isPicking, date == nil {
            onChange(hidesYear ? Self.dayMonth(day: day, month: month) : Self.today)
        }
        withAnimation(ProfileV3Theme.Motion.selection) { isPicking.toggle() }
    }

    private func syncWheels(from date: Date?) {
        let parts = Calendar(identifier: .gregorian).dateComponents([.day, .month], from: date ?? Self.today)
        day = parts.day ?? 1
        month = parts.month ?? 1
    }

    private func commitDayMonth() {
        let picked = Self.dayMonth(day: day, month: month)
        let clamped = Calendar(identifier: .gregorian).component(.day, from: picked)
        if clamped != day { day = clamped }
        onChange(picked)
    }

    private static func dayMonth(day: Int, month: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        let monthDate = calendar.date(from: DateComponents(year: 2000, month: month, day: 1)) ?? .now
        let dayCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 28
        return calendar.date(from: DateComponents(year: 2000, month: month, day: min(day, dayCount), hour: 12)) ?? .now
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
