import Foundation
import os

enum ProfileV3ISODate {
    static func parse(_ raw: String) -> Date? {
        fractional.withLock { $0.date(from: raw) } ?? plain.withLock { $0.date(from: raw) }
    }

    private static let fractional: OSAllocatedUnfairLock<ISO8601DateFormatter> = {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return OSAllocatedUnfairLock(uncheckedState: parser)
    }()

    private static let plain: OSAllocatedUnfairLock<ISO8601DateFormatter> = {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime]
        return OSAllocatedUnfairLock(uncheckedState: parser)
    }()
}
