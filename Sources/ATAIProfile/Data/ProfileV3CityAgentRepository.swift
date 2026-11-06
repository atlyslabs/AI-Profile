import Foundation

struct ProfileV3CityAgentRepository: ProfileV3AgentRepository {
    let cityID: String
    var save: ProfileV3BoardAction?
    let base: any ProfileV3CityPreferencesRepository

    func loadAgentFlow(agentID _: String, profileID: String?) async throws -> ProfileV3AgentFlow {
        .preferences(try await base.loadCity(cityID, profileID: profileID).form)
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID _: String?, profileIDs _: [String]?) async throws -> String? {
        try await base.saveCityPreferences(form, cityID: cityID, action: save)
        return nil
    }

    func loadPreviousPassports(profileID: String?) async throws -> ProfileV3PreviousPassports {
        try await base.loadPreviousPassports(profileID: profileID)
    }

    func loadPassportScan(profileID: String?) async throws -> ProfileV3PassportScan {
        try await base.loadPassportScan(profileID: profileID)
    }

    func uploadPassportScan(_ side: ProfileV3PassportSide, data: Data, profileID: String?) async throws
        -> ProfileV3PassportScanResult {
        try await base.uploadPassportScan(side, data: data, profileID: profileID)
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen {
        try await base.loadPassportReason()
    }

    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed {
        try await base.loadPassportHowUsed()
    }

    func updatePassport(reason: String, profileID: String?) async throws {
        try await base.updatePassport(reason: reason, profileID: profileID)
    }

    func loadPreferenceSources(_ source: ProfileV3SectionSource, profileID: String?) async throws
        -> ProfileV3PreferenceSources {
        try await base.loadCitySources(source, cityID: cityID)
    }

    func loadRidePicker(agentType: String, profileID: String?) async throws -> ProfileV3RidePicker {
        try await base.loadRidePicker(agentType: agentType, profileID: profileID)
    }

    func loadRideRegions() async throws -> ProfileV3RideRegions {
        try await base.loadRideRegions()
    }
}
