import Combine
import Foundation

@MainActor
final class ProfileV3AddPastTripViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var selectedCountries: [ProfileV3Country] = []
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var screen: ProfileV3AddTripScreen?
    @Published private(set) var isLoadingScreen = false

    private let profileID: String
    private let existing: [ProfileV3PastTrip]
    private let repository: any ProfileV3PastTripsRepository
    private let onSaved: ([ProfileV3PastTripDraft]) -> Void
    private let onFailed: () -> Void
    private var loadTask: Task<Void, Never>?

    init(
        profileID: String,
        existing: [ProfileV3PastTrip],
        repository: any ProfileV3PastTripsRepository,
        screen: ProfileV3AddTripScreen? = nil,
        onSaved: @escaping ([ProfileV3PastTripDraft]) -> Void,
        onFailed: @escaping () -> Void
    ) {
        self.profileID = profileID
        self.existing = existing
        self.repository = repository
        self.screen = screen
        self.onSaved = onSaved
        self.onFailed = onFailed
    }

    var countries: [ProfileV3Country]? {
        guard let countries = screen?.countries, !countries.isEmpty else { return nil }
        return countries
    }

    var title: String { screen?.countryTitle ?? "" }

    var searchPlaceholder: String { screen?.searchPlaceholder ?? "" }

    var countryCTA: String { screen?.countryCTA ?? "" }

    var canSubmit: Bool {
        !selectedCountries.isEmpty && !isSubmitting && screen?.submit != nil
    }

    func load() {
        guard screen == nil, !isLoadingScreen else { return }
        isLoadingScreen = true
        let repository = repository
        let profileID = profileID
        loadTask = Task { [weak self] in
            let screen = try? await repository.loadAddTrip(profileID: profileID)
            guard let self, !Task.isCancelled else { return }
            isLoadingScreen = false
            guard let screen else { return }
            self.screen = screen
        }
    }

    func select(_ country: ProfileV3Country) {
        guard !isSubmitting else { return }
        errorMessage = nil
        if let index = selectedCountries.firstIndex(of: country) {
            selectedCountries.remove(at: index)
        } else {
            selectedCountries.append(country)
        }
    }

    func submit() {
        guard canSubmit, let action = screen?.submit else { return }
        let drafts = selectedCountries.map { ProfileV3PastTripDraft(countryCode: $0.code) }
        guard !drafts.contains(where: { draft in existing.contains { $0.matches(draft) } }) else {
            errorMessage = ProfileV3Strings.pastTripDuplicate
            return
        }
        errorMessage = nil
        isSubmitting = true
        let repository = repository
        Task { [weak self] in
            do {
                try await repository.addPastTrips(action, countries: drafts.map(\.countryCode))
                guard let self else { return }
                isSubmitting = false
                onSaved(drafts)
            } catch {
                guard let self else { return }
                isSubmitting = false
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.pastTripSaveFailed)
                onFailed()
            }
        }
    }

    func cancel() {
        loadTask?.cancel()
    }
}
