import Foundation

extension Collection {
    var nonEmpty: Self? {
        isEmpty ? nil : self
    }

    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
