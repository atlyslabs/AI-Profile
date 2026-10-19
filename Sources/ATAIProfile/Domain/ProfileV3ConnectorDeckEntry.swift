import Foundation

struct ProfileV3ConnectorDeckEntry: Identifiable, Equatable {
    let id: String
    let headline: String
    let account: String
    let blurb: String
    let hint: String
    let icon: ProfileV3ConnectorIcon
    var isApp = false
}
