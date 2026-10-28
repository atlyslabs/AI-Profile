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
        case addDates(ProfileV3PastTrip)
        case edit(ProfileV3PastTrip)
    }

    @Published private(set) var step: Step
    @Published var query = ""
    @Published private(set) var selectedCountry: ProfileV3Country?
    @Published private(set) var selectedCountries: [ProfileV3Country] = []
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
    private let addsWithoutDate: Bool
    private let onSaved: ([ProfileV3PastTripDraft]) -> Void
    private let onFailed: () -> Void
    private var loadTask: Task<Void, Never>?

    init(
        mode: Mode,
        profileID: String,
        existing: [ProfileV3PastTrip],
        repository: any ProfileV3PastTripsRepository,
        screen: ProfileV3AddTripScreen? = nil,
        editDuration: ProfileV3TripDuration? = nil,
        addsWithoutDate: Bool = false,
        onSaved: @escaping ([ProfileV3PastTripDraft]) -> Void,
        onFailed: @escaping () -> Void
    ) {
        self.mode = mode
        self.profileID = profileID
        self.existing = existing
        self.repository = repository
        self.screen = screen
        self.editDuration = editDuration
        self.addsWithoutDate = addsWithoutDate
        self.onSaved = onSaved
        self.onFailed = onFailed
        switch mode {
        case .add:
            pinnedCountry = nil
            step = .country
        case .addDates(let trip), .edit(let trip):
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

    var asksForDate: Bool {
        guard case .add = mode else { return true }
        guard !addsWithoutDate else { return false }
        return screen.map { $0.duration != nil } ?? true
    }

    var selectsMany: Bool { mode == .add && !asksForDate }

    var duration: ProfileV3TripDuration {
        switch mode {
        case .add: return screen?.duration ?? .fallback()
        case .addDates: return screen?.duration ?? editDuration ?? .fallback()
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
        guard selectedCountry != nil, !isSubmitting, submitAction != nil else { return false }
        return !asksForDate || selectedDate != nil
    }

    var canSubmitCountries: Bool {
        !selectedCountries.isEmpty && !isSubmitting && submitAction != nil
    }

    var canConfirmCountry: Bool { asksForDate ? canContinue : canSubmitCountries }

    var canGoBack: Bool { step == .duration && pinnedCountry == nil && !isSubmitting }

    var stepIndex: Int { isEditing ? 0 : Step.allCases.firstIndex(of: step) ?? 0 }

    var stepCount: Int { isEditing ? 1 : Step.allCases.count }

    var title: String {
        step == .country ? screen?.countryTitle ?? "" : duration.title
    }

    var submitTitle: String { duration.ctaLabel }

    func load() {
        guard !isEditing, screen == nil, !isLoadingScreen else { return }
        isLoadingScreen = true
        let repository = repository
        let profileID = profileID
        loadTask = Task { [weak self] in
            let screen = try? await repository.loadAddTrip(profileID: profileID)
            guard let self, !Task.isCancelled else { return }
            isLoadingScreen = false
            guard let screen else { return }
            self.screen = screen
            if step == .country || pinnedCountry != nil { applyDefaults() }
        }
    }

    func select(_ country: ProfileV3Country) {
        guard !isSubmitting else { return }
        errorMessage = nil
        guard selectsMany else {
            selectedCountry = country
            return
        }
        if let index = selectedCountries.firstIndex(of: country) {
            selectedCountries.remove(at: index)
        } else {
            selectedCountries.append(country)
        }
    }

    func confirmCountry() {
        if asksForDate {
            continueToDuration()
        } else {
            submitCountries()
        }
    }

    func continueToDuration() {
        guard canContinue, asksForDate else { return }
        withAnimation(ProfileV3Theme.Motion.tripStep) { step = .duration }
    }

    func backToCountry() {
        guard canGoBack else { return }
        errorMessage = nil
        withAnimation(ProfileV3Theme.Motion.tripStep) { step = .country }
    }

    func submit() {
        guard canSubmit, let country = selectedCountry, let action = submitAction else { return }
        let date = asksForDate ? selectedDate : nil
        let draft = ProfileV3PastTripDraft(countryCode: country.code, date: date)
        guard !existing.contains(where: { $0.id != editedTripID && $0.duplicates(draft) }) else {
            errorMessage = ProfileV3Strings.pastTripDuplicate
            return
        }
        errorMessage = nil
        isSubmitting = true
        let repository = repository
        let mode = mode
        Task { [weak self] in
            do {
                switch (mode, date) {
                case (.add, _), (.addDates, _):
                    try await repository.addPastTrip(action, country: draft.countryCode, date: date)
                case (.edit, let date?):
                    try await repository.editPastTrip(action, year: date.year, month: date.month)
                case (.edit, nil):
                    throw ProfileV3RepositoryError.unavailable
                }
                guard let self else { return }
                isSubmitting = false
                onSaved([draft])
            } catch {
                guard let self else { return }
                isSubmitting = false
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.pastTripSaveFailed)
                onFailed()
            }
        }
    }

    func submitCountries() {
        guard canSubmitCountries, let action = submitAction else { return }
        let drafts = selectedCountries.map { ProfileV3PastTripDraft(countryCode: $0.code, date: nil) }
        guard !drafts.contains(where: { draft in existing.contains { $0.duplicates(draft) } }) else {
            errorMessage = ProfileV3Strings.pastTripDuplicate
            return
        }
        errorMessage = nil
        isSubmitting = true
        let repository = repository
        Task { [weak self] in
            var added: [ProfileV3PastTripDraft] = []
            do {
                for draft in drafts {
                    try await repository.addPastTrip(action, country: draft.countryCode, date: nil)
                    added.append(draft)
                }
                guard let self else { return }
                isSubmitting = false
                onSaved(added)
            } catch {
                guard let self else { return }
                isSubmitting = false
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.pastTripSaveFailed)
                if added.isEmpty {
                    onFailed()
                } else {
                    onSaved(added)
                }
            }
        }
    }

    func cancel() {
        loadTask?.cancel()
    }

    private var submitAction: ProfileV3BoardAction? {
        switch mode {
        case .add, .addDates: return screen?.submit
        case .edit(let trip): return trip.edit?.submit
        }
    }

    private var editedTripID: String? {
        if case .edit(let trip) = mode { return trip.id }
        return nil
    }

    private var selectedDate: ProfileV3TripYearMonth? {
        guard let selectedYear, let selectedMonth else { return nil }
        return ProfileV3TripYearMonth(year: selectedYear, month: selectedMonth)
    }

    private func applyDefaults() {
        var initial = duration.defaultValue ?? duration.max
        if case .edit(let trip) = mode, let date = trip.date {
            initial = date
        }
        selectedYear = initial?.year ?? years.last
        selectedMonth = initial?.month ?? months.last
    }

    private func clampMonth() {
        errorMessage = nil
        guard let selectedMonth, !months.contains(selectedMonth) else { return }
        self.selectedMonth = months.last
    }
}
