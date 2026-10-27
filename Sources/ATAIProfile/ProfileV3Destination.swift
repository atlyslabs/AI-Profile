import Combine

public enum ProfileV3Destination: Sendable, Equatable {
    case addTraveller
    case addLoyaltyProgramme
}

@MainActor
final class ProfileV3PendingDestination: ObservableObject {
    static let shared = ProfileV3PendingDestination()

    @Published private(set) var destination: ProfileV3Destination?

    func post(_ destination: ProfileV3Destination) {
        self.destination = destination
    }

    func take() -> ProfileV3Destination? {
        defer { destination = nil }
        return destination
    }
}
