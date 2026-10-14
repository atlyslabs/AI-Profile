import SwiftUI

extension Color {
    init(hex: String) {
        let sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard let value = UInt64(sanitized, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }

        switch sanitized.count {
        case 6:
            self.init(
                red: Self.channel(value, shift: 16),
                green: Self.channel(value, shift: 8),
                blue: Self.channel(value, shift: 0)
            )
        case 8:
            self.init(
                red: Self.channel(value, shift: 24),
                green: Self.channel(value, shift: 16),
                blue: Self.channel(value, shift: 8),
                opacity: Self.channel(value, shift: 0)
            )
        default:
            self.init(red: 0, green: 0, blue: 0)
        }
    }

    private static func channel(_ value: UInt64, shift: Int) -> Double {
        Double((value >> shift) & 0xFF) / 255
    }
}
