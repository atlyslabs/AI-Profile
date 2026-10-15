import DittoRuntimeStrings
import Foundation

enum ProfileV3DittoRuntimeStrings {
    private static let loader = DittoRuntimeStringsLoader(bundle: .module, projectId: "ai-profile")

    static func lookup(_ key: String, _ table: String, _ value: String) -> String {
        loader.lookup(key, table, value)
    }
}
