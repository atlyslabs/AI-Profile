import UIKit
import UniformTypeIdentifiers

enum ProfileV3VaultClipboard {
    static let lifetime: TimeInterval = 30

    @MainActor private static var expiringChanges: [UIPasteboard.Name: Int] = [:]

    @MainActor
    static func expire(_ secret: String, after lifetime: TimeInterval = ProfileV3VaultClipboard.lifetime, pasteboard: UIPasteboard = .general) {
        guard pasteboard.changeCount != expiringChanges[pasteboard.name], pasteboard.string == secret else { return }
        pasteboard.setItems(
            [[UTType.utf8PlainText.identifier: secret]],
            options: [.localOnly: true, .expirationDate: Date().addingTimeInterval(lifetime)]
        )
        expiringChanges[pasteboard.name] = pasteboard.changeCount
    }
}
