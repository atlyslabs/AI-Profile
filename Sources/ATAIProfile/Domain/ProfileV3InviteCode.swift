import Foundation

public struct ProfileV3InviteCode: Equatable, Sendable {
    public let code: String
    public let maxUses: Int
    public let usedCount: Int

    public init(code: String, maxUses: Int, usedCount: Int) {
        self.code = code
        self.maxUses = max(maxUses, 0)
        self.usedCount = min(max(usedCount, 0), max(maxUses, 0))
    }

    public var remainingUses: Int { maxUses - usedCount }

    var spacedCode: String {
        code.map(String.init).joined(separator: " ")
    }

    var remainingLabel: String {
        remainingUses < 10 ? "0\(remainingUses)" : "\(remainingUses)"
    }
}
