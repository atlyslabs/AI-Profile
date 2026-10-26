import Foundation

enum ProfileV3GlobeMapper {
    static func stat(_ dto: ProfileV3GlobeStatDTO) -> ProfileV3TravelStat? {
        guard let key = statKey(dto.key) else { return nil }
        return ProfileV3TravelStat(
            key: key,
            label: dto.label ?? "",
            value: dto.value?.intValue,
            unit: dto.unit?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        )
    }

    private static func statKey(_ raw: String?) -> ProfileV3TravelStat.Key? {
        guard let raw else { return nil }
        let normalised = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return ProfileV3TravelStat.Key(rawValue: normalised)
    }
}
