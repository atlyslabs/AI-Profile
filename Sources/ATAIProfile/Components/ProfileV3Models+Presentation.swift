import Foundation
import os

extension ProfileV3Home {
    func kycStatusText(showsExpiryDate: Bool) -> String? {
        if needsKYCReconnect { return kycStatusLabel ?? ProfileV3Strings.reconnectGmail }
        switch kycStatus {
        case .complete:
            return nil
        case .notStarted:
            return kycStatusLabel ?? ProfileV3Strings.kycIncomplete
        case .expired(let date):
            if let kycLine {
                guard showsExpiryDate, let subtitle = kycLine.subtitle else { return kycLine.title }
                return ProfileV3Strings.kycStatusLine(kycLine.title, subtitle)
            }
            guard showsExpiryDate, let date = date.nonEmpty else { return ProfileV3Strings.kycExpired }
            return ProfileV3Strings.kycExpiredOn(date)
        }
    }
}

extension ProfileV3WorldPass {
    var kycTitle: String { kycLine?.title ?? kycStatus.title }

    var kycSubtitle: String? {
        guard let kycLine else { return kycStatus.subtitle }
        return kycLine.subtitle
    }

    var kycAccessibilityDescription: String {
        [kycTitle, kycSubtitle].compactMap { $0 }.joined(separator: ", ")
    }
}

extension ProfileV3UpdateStamp {
    func text(relativeTo now: Date = .now) -> String {
        switch self {
        case .date(let date):
            return Self.relativeFormatter.withLock {
                $0.localizedString(for: min(date, now), relativeTo: now)
            }
        case .label(let label):
            return label
        }
    }

    private static let relativeFormatter: OSAllocatedUnfairLock<RelativeDateTimeFormatter> = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        return OSAllocatedUnfairLock(uncheckedState: formatter)
    }()
}

extension ProfileV3Agent {
    var sheetTag: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ProfileV3Strings.agentFallbackTag }
        if trimmed.lowercased().hasSuffix(ProfileV3Strings.agentSuffix) { return trimmed }
        return ProfileV3Strings.agentTag(trimmed)
    }
}

extension ProfileV3SliderField {
    var readout: (value: String, detail: String?)? {
        if optOut?.isOn == true {
            return (ProfileV3Strings.ratherNotSay, nil)
        }
        switch format {
        case .unit(let unit):
            return (ProfileV3Strings.unitValue(Int(value.rounded()), unit: unit), nil)
        case .feetAndInches:
            let total = Int(value.rounded())
            let inchesPerFoot = Int(ProfileV3Theme.Measure.inchesPerFoot)
            let feet = total / inchesPerFoot
            let inches = total % inchesPerFoot
            return ("\(feet)'\(inches)\"", nil)
        case .centimetres:
            let inchesPerFoot = Int(ProfileV3Theme.Measure.inchesPerFoot)
            let totalInches = Int((value / ProfileV3Theme.Measure.inchesPerCentimetre).rounded())
            let feet = totalInches / inchesPerFoot
            let remainder = totalInches % inchesPerFoot
            let height = remainder == 0
                ? ProfileV3Strings.heightFeet(feet)
                : ProfileV3Strings.heightFeetInches(feet, remainder)
            return (height, ProfileV3Strings.heightCentimetres(Int(value.rounded())))
        case .levels(let labels):
            guard !labels.isEmpty else { return nil }
            let index = Int((fraction * Double(labels.count - 1)).rounded())
            return (labels[min(max(index, 0), labels.count - 1)], nil)
        case nil:
            return nil
        }
    }

    func previewing(_ value: Double?) -> ProfileV3SliderField {
        guard let value else { return self }
        var field = self
        field.value = value
        return field
    }
}

extension ProfileV3TravelStat {
    var displayValue: String {
        guard let value else { return ProfileV3Strings.statPlaceholder }
        guard key == .distance else { return value.formatted() }
        let unit = unit?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let unit, !unit.isEmpty, unit != "km" else {
            return ProfileV3Strings.distanceKilometres(value)
        }
        return "\(value.formatted()) \(unit)"
    }
}

extension ProfileV3Connector.Status {
    var accessibilityValue: String {
        switch self {
        case .connected: return ProfileV3Strings.connectorConnected
        case .needsAttention: return ProfileV3Strings.connectorNeedsAttention
        }
    }
}

extension ProfileV3KYCStatus {
    var title: String {
        switch self {
        case .complete: return ProfileV3Strings.kycComplete
        case .notStarted: return ProfileV3Strings.kycIncomplete
        case .expired: return ProfileV3Strings.kycExpired
        }
    }

    var subtitle: String? {
        switch self {
        case .complete(let validTill):
            return validTill.nonEmpty.map(ProfileV3Strings.activeTill)
        case .expired(let date): return date.nonEmpty.map(ProfileV3Strings.expiredOn)
        case .notStarted: return nil
        }
    }
}

extension ProfileV3Benefit.Status {
    var accessibilityDescription: String {
        switch self {
        case .locked:
            return ProfileV3Strings.kycIncomplete
        case .active(let validTill):
            return validTill
        case .partiallyRedeemed(let usage, let validTill, _):
            return [usage, validTill].compactMap(\.nonEmpty).joined(separator: ", ")
        case .redeemed(let on):
            return on
        }
    }
}

extension ProfileV3ProgrammeCategory {
    var title: String {
        switch self {
        case .all: return ProfileV3Strings.categoryAll
        case .creditCards: return ProfileV3Strings.categoryCreditCards
        case .hotels: return ProfileV3Strings.categoryHotels
        case .flights: return ProfileV3Strings.flights
        case .travelPasses: return ProfileV3Strings.categoryTravelPasses
        }
    }
}

extension ProfileV3Route {
    var actionTitle: String? {
        switch self {
        case .loyaltyAdd: return ProfileV3Strings.addProgramme
        case .programsPage: return ProfileV3Strings.loyaltyProgrammes
        case .benefitsSheet: return ProfileV3Strings.viewAllBenefits
        default: return nil
        }
    }
}

extension ProfileV3Passport.Status {
    var label: String {
        switch self {
        case .active: return ProfileV3Strings.passportActive
        case .expired: return ProfileV3Strings.passportExpired
        }
    }
}
