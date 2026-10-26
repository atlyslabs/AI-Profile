import Combine
import Foundation
import SwiftUI

@MainActor
final class ProfileV3AddPastTripViewModel: ObservableObject {
    enum Step: CaseIterable {
        case country
        case duration
    }

    enum Mode: Equatable {
        case add
        case edit(ProfileV3PastTrip)
    }

    @Published private(set) var step: Step
    @Published var query = ""
    @Published private(set) var selectedCountry: ProfileV3Country?
    @Published var selectedYear: Int? {
        didSet { clampMonth() }
    }
    @Published var selectedMonth: Int?
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var screen: ProfileV3AddTripScreen?
    @Published private(set) var isLoadingScreen = false

    let mode: Mode
    let pinnedCountry: ProfileV3Country?

    private let profileID: String
    private let existing: [ProfileV3PastTrip]
    private let repository: any ProfileV3PastTripsRepository
    private let editDuration: ProfileV3TripDuration?
    private let onSaved: (ProfileV3PastTripDraft) -> Void
    private let onFailed: () -> Void
    private var loadTask: Task<Void, Never>?

    init(
        mode: Mode,
        profileID: String,
        existing: [ProfileV3PastTrip],
        repository: any ProfileV3PastTripsRepository,
        screen: ProfileV3AddTripScreen? = nil,
        editDuration: ProfileV3TripDuration? = nil,
        onSaved: @escaping (ProfileV3PastTripDraft) -> Void,
        onFailed: @escaping () -> Void
    ) {
        self.mode = mode
        self.profileID = profileID
        self.existing = existing
        self.repository = repository
        self.screen = screen
        self.editDuration = editDuration
        self.onSaved = onSaved
        self.onFailed = onFailed
        switch mode {
        case .add:
            pinnedCountry = nil
            step = .country
        case .edit(let trip):
            let country = ProfileV3Country(code: trip.countryCode, name: trip.countryName)
            pinnedCountry = country
            selectedCountry = country
            step = .duration
        }
        applyDefaults()
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var duration: ProfileV3TripDuration {
        switch mode {
        case .add: return screen?.duration ?? .fallback()
        case .edit: return editDuration ?? .fallback()
        }
    }

    var years: [Int] { duration.pickableYears }

    var months: [Int] { duration.months(in: selectedYear).map(\.value) }

    func monthLabel(_ value: Int) -> String {
        duration.label(forMonth: value)
    }

    var countries: [ProfileV3Country]? {
        guard let countries = screen?.countries, !countries.isEmpty else { return nil }
        return countries
    }

    var searchPlaceholder: String { screen?.searchPlaceholder ?? "" }

    var countryCTA: String { screen?.countryCTA ?? "" }

    var canContinue: Bool { selectedCountry != nil }

    var canSubmit: Bool {
        selectedCountry != nil && selectedYear != nil && selectedMonth != nil && !isSubmitting && submitAction != nil
    }

    var stepIndex: Int { isEditing ? 0 : Step.allCases.firstIndex(of: step) ?? 0 }

    var stepCount: Int { isEditing ? 1 : Step.allCases.count }

    var title: String {
        step == .country ? screen?.countryTitle ?? "" : duration.title
    }

    var submitTitle: String { duration.ctaLabel }

    func load() {
        guard case .add = mode, screen == nil, !isLoadingScreen else { return }
        isLoadingScreen = true
        let repository = repository
        let profileID = profileID
        loadTask = Task { [weak self] in
            let screen = try? await repository.loadAddTrip(profileID: profileID)
            guard let self, !Task.isCancelled else { return }
            isLoadingScreen = false
            guard let screen else { return }
            self.screen = screen
            if step == .country { applyDefaults() }
        }
    }

    func select(_ country: ProfileV3Country) {
        guard !isSubmitting else { return }
        selectedCountry = country
        errorMessage = nil
    }

    func continueToDuration() {
        guard canContinue else { return }
        withAnimation(ProfileV3Theme.Motion.tripStep) { step = .duration }
    }

    func backToCountry() {
        guard step == .duration, !isSubmitting, !isEditing else { return }
        errorMessage = nil
        withAnimation(ProfileV3Theme.Motion.tripStep) { step = .country }
    }

    func submit() {
        guard canSubmit, let country = selectedCountry, let year = selectedYear, let month = selectedMonth,
              let action = submitAction else {
            return
        }
        let draft = ProfileV3PastTripDraft(countryCode: country.code, year: year, month: month)
        guard !existing.contains(where: { $0.id != editedTripID && $0.matches(draft) }) else {
            errorMessage = ProfileV3Strings.pastTripDuplicate
            return
        }
        errorMessage = nil
        isSubmitting = true
        let repository = repository
        let mode = mode
        Task { [weak self] in
            do {
                switch mode {
                case .add:
                    try await repository.addPastTrip(action, country: draft.countryCode, year: year, month: month)
                case .edit:
                    try await repository.editPastTrip(action, year: year, month: month)
                }
                guard let self else { return }
                isSubmitting = false
                onSaved(draft)
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

    private var submitAction: ProfileV3BoardAction? {
        switch mode {
        case .add: return screen?.submit
        case .edit(let trip): return trip.edit?.submit
        }
    }

    private var editedTripID: String? {
        if case .edit(let trip) = mode { return trip.id }
        return nil
    }

    private func applyDefaults() {
        switch mode {
        case .add:
            let initial = duration.defaultValue ?? duration.max
            selectedYear = initial?.year ?? years.last
            selectedMonth = initial?.month ?? months.last
        case .edit(let trip):
            selectedYear = trip.year
            selectedMonth = trip.month
        }
    }

    private func clampMonth() {
        errorMessage = nil
        guard let selectedMonth, !months.contains(selectedMonth) else { return }
        self.selectedMonth = months.last
    }
}
