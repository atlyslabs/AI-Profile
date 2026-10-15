import Foundation

enum ProfileV3AgentSubmissionValue: Encodable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case list([String])
    case items([ProfileV3AgentSubmissionItem])
    case object([String: String])
    case null

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            if let whole = Int(exactly: value.rounded()), value == value.rounded() {
                try container.encode(whole)
            } else {
                try container.encode(value)
            }
        case .bool(let value):
            try container.encode(value)
        case .list(let values):
            try container.encode(values)
        case .items(let values):
            try container.encode(values)
        case .object(let values):
            try container.encode(values)
        case .null:
            try container.encodeNil()
        }
    }
}

struct ProfileV3AgentSubmissionItem: Encodable, Equatable {
    let value: String
    let count: Int?
}

struct ProfileV3AgentSubmissionRequest: Encodable, Equatable {
    let action: String
    let agentType: String
    let profileID: String?
    let values: [String: ProfileV3AgentSubmissionValue]

    enum CodingKeys: String, CodingKey {
        case action
        case agentType = "agent_type"
        case profileID = "profile_id"
        case values
    }
}

enum ProfileV3AgentSubmission {
    private static let action = "save_agent_preferences"

    private static func request(
        for form: ProfileV3AgentForm,
        profileID: String?,
        residuals: ProfileV3AgentResiduals = .empty
    ) -> ProfileV3AgentSubmissionRequest {
        ProfileV3AgentSubmissionRequest(
            action: residuals.saveAction ?? action,
            agentType: agentType(for: form.agentID),
            profileID: profileID,
            values: values(for: form, residuals: residuals)
        )
    }

    static func body(
        for form: ProfileV3AgentForm,
        profileID: String?,
        residuals: ProfileV3AgentResiduals = .empty
    ) throws -> Data {
        try JSONEncoder().encode(request(for: form, profileID: profileID, residuals: residuals))
    }

    private static func values(
        for form: ProfileV3AgentForm,
        residuals: ProfileV3AgentResiduals = .empty
    ) -> [String: ProfileV3AgentSubmissionValue] {
        var values = residuals.passthrough
        for section in form.sections {
            if case .baggage(let field) = section.control {
                for tab in field.tabs {
                    values[tab.id] = baggageValue(tab)
                }
                continue
            }
            guard let value = value(for: section, residuals: residuals) else { continue }
            values[section.id] = value
        }
        if let key = residuals.lockScreenFieldKey, let card = form.medicalCard {
            values[key] = .bool(card.showsOnLockScreen)
        }
        return values
    }

    private static func agentType(for agentID: String) -> String {
        ProfileV3AgentID(rawValue: agentID)?.apiValue ?? agentID.replacingOccurrences(of: "-", with: "_")
    }

    private static func value(
        for section: ProfileV3FormSection,
        residuals: ProfileV3AgentResiduals
    ) -> ProfileV3AgentSubmissionValue? {
        switch section.control {
        case .chips(let field):
            return selection(field.selection, ordered: ordering(of: field), allowsMultiple: field.allowsMultiple)
        case .cards(let field):
            return selection(field.selection, ordered: field.options.map(\.id), allowsMultiple: field.allowsMultiple)
        case .slider(let field):
            return field.optOut?.isOn == true ? .null : .number(field.value)
        case .text(let field):
            guard let contact = residuals.contacts[section.id] else { return .string(field.value) }
            return contactValue(contact, text: field.value)
        case .date(let field):
            guard let date = field.value else { return .null }
            let format = residuals.dateFormats[section.id] ?? .iso
            return .string(ProfileV3AgentDateCodec.string(from: date, format: format))
        case .cars(let field):
            return field.selection.map(ProfileV3AgentSubmissionValue.string) ?? .null
        case .passport, .baggage:
            return nil
        }
    }

    private static func baggageValue(_ tab: ProfileV3BaggageTab) -> ProfileV3AgentSubmissionValue {
        .items(tab.items.compactMap { item in
            let quantity = tab.quantity(of: item.id)
            guard quantity > 0 else { return nil }
            return ProfileV3AgentSubmissionItem(value: item.id, count: item.isCountable ? quantity : nil)
        })
    }

    private static func ordering(of field: ProfileV3ChipField) -> [String] {
        field.options.map(\.id) + (field.picker?.catalogue.map(\.id) ?? [])
    }

    private static func selection(
        _ selection: Set<String>,
        ordered: [String],
        allowsMultiple: Bool
    ) -> ProfileV3AgentSubmissionValue {
        var seen = Set<String>()
        var ids = ordered.filter { selection.contains($0) && seen.insert($0).inserted }
        ids.append(contentsOf: selection.subtracting(ids).sorted())
        guard allowsMultiple else { return ids.first.map(ProfileV3AgentSubmissionValue.string) ?? .null }
        return .list(ids)
    }

    private static func contactValue(
        _ contact: ProfileV3ContactSnapshot,
        text: String
    ) -> ProfileV3AgentSubmissionValue {
        let edited = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let entered = edited.isEmpty ? nil : edited
        var fields: [String: String] = [:]
        if let email = contact.rendersMobile ? contact.email : entered { fields["email"] = email }
        if let mobile = contact.rendersMobile ? entered : contact.mobileNumber { fields["mobile_number"] = mobile }
        return fields.isEmpty ? .null : .object(fields)
    }
}
