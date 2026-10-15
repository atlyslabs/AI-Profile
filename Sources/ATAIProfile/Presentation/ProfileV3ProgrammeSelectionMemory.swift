import Foundation

@MainActor
final class ProfileV3ProgrammeSelectionMemory {
    private var itemIDs: [String: String] = [:]

    func itemID(for profileID: String) -> String? {
        itemIDs[profileID]
    }

    func remember(_ itemID: String?, for profileID: String) {
        itemIDs[profileID] = itemID
    }
}
