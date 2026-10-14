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

    @Published private(set) var step: Step = .country
    @Published var query = ""
    @Published private(set) var selectedCountry: ProfileV3Country?
    @Published var selectedYear: Int? {
        didSet { clampMonth() }
    }
    @Published var selectedMonth: Int?
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?

    let mode: Mode
    let years: [Int]
    let pinnedCountry: ProfileV3Country?

    private let profileID: String
    private let existing: [ProfileV3PastTrip]
    private let repository: any ProfileV3PastTripsRepository
    private let currentYear: Int
    private let currentMonth: Int
    private let onSaved: (ProfileV3PastTrip) -> Void
    private let onFailed: () -> Void

    init(
        mode: Mode,
        profileID: String,
        existing: [ProfileV3PastTrip],
        repository: any ProfileV3PastTripsRepository,
        now: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian),
        onSaved: @escaping (ProfileV3PastTrip) -> Void,
        onFailed: @escaping () -> Void
    ) {
        self.mode = mode
        self.profileID = profileID
        self.existing = existing
        self.repository = repository
        self.onSaved = onSaved
        self.onFailed = onFailed
        let today = calendar.dateComponents([.year, .month], from: now)
        let year = today.year ?? 0
        let month = today.month ?? 1
        currentYear = year
        currentMonth = month
        years = Array((year - ProfileV3Theme.Counts.pastTripYears)...year)
        switch mode {
        case .add:
            pinnedCountry = nil
            selectedYear = year
            selectedMonth = month
        case .edit(let trip):
            pinnedCountry = ProfileV3Country(code: trip.countryCode)
            selectedCountry = pinnedCountry
            selectedYear = trip.year
            selectedMonth = trip.month
        }
    }

    var months: [Int] {
        Array(1...(selectedYear == currentYear ? currentMonth : ProfileV3Theme.Counts.monthsInYear))
    }

    var canContinue: Bool { selectedCountry != nil }

    var canSubmit: Bool {
        selectedCountry != nil && selectedYear != nil && selectedMonth != nil && !isSubmitting
    }

    var stepIndex: Int { Step.allCases.firstIndex(of: step) ?? 0 }

    var stepCount: Int { Step.allCases.count }

    var title: String {
        step == .country ? ProfileV3Strings.searchForCountry : ProfileV3Strings.selectDuration
    }

    var submitTitle: String {
        if case .edit = mode { return ProfileV3Strings.saveTrip }
        return ProfileV3Strings.addCountry
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
        guard step == .duration, !isSubmitting else { return }
        errorMessage = nil
        withAnimation(ProfileV3Theme.Motion.tripStep) { step = .country }
    }

    func submit() {
        guard canSubmit, let country = selectedCountry, let year = selectedYear, let month = selectedMonth else {
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
        let profileID = profileID
        let mode = mode
        Task { [weak self] in
            do {
                let trip: ProfileV3PastTrip
                switch mode {
                case .add:
                    trip = try await repository.addPastTrip(draft, profileID: profileID)
                case .edit(let original):
                    trip = try await repository.updatePastTrip(id: original.id, with: draft, profileID: profileID)
                }
                guard let self else { return }
                isSubmitting = false
                onSaved(trip)
            } catch {
                guard let self else { return }
                isSubmitting = false
                errorMessage = ProfileV3Strings.pastTripSaveFailed
                onFailed()
            }
        }
    }

    private var editedTripID: String? {
        if case .edit(let trip) = mode { return trip.id }
        return nil
    }

    private func clampMonth() {
        errorMessage = nil
        guard let selectedMonth, !months.contains(selectedMonth) else { return }
        self.selectedMonth = months.last
    }
}
