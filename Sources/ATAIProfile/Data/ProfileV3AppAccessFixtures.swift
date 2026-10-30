import Foundation

#if DEBUG
final class ProfileV3AppAccessStore: @unchecked Sendable {
    static let shared = ProfileV3AppAccessStore()
    static let latency: Duration = .milliseconds(600)
    static let passwordPrefix = "password-"

    private let lock = NSLock()
    private var content: ProfileV3AppAccess
    private var nextPasswordID = 0

    init(content: ProfileV3AppAccess = ProfileV3AppAccessFixtures.content) {
        self.content = content
    }

    func snapshot() -> ProfileV3AppAccess {
        lock.lock()
        defer { lock.unlock() }
        return content
    }

    func connect(_ appID: String, credentials: ProfileV3AppCredentials) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let index = content.apps.firstIndex(where: { $0.id == appID }) else {
            throw ProfileV3Error.invalidRequest(message: nil)
        }
        content.apps[index].username = credentials.username
        content.apps[index].isConnected = true
    }

    func addPassword(_ credentials: ProfileV3AppCredentials) {
        lock.lock()
        defer { lock.unlock() }
        nextPasswordID += 1
        content.apps.append(
            ProfileV3LinkedApp(
                id: "\(Self.passwordPrefix)\(nextPasswordID)",
                name: credentials.websiteURL?.host() ?? credentials.website,
                iconURL: nil,
                blurb: credentials.website,
                username: credentials.username,
                isConnected: true
            )
        )
    }

    func disconnect(_ appID: String) {
        lock.lock()
        defer { lock.unlock() }
        if appID.hasPrefix(Self.passwordPrefix) {
            content.apps.removeAll { $0.id == appID }
            return
        }
        guard let index = content.apps.firstIndex(where: { $0.id == appID }) else { return }
        content.apps[index].username = nil
        content.apps[index].isConnected = false
    }
}

enum ProfileV3AppAccessFixtures {
    static let content = ProfileV3AppAccess(
        autoConnected: [
            ProfileV3AutoConnectedApp(id: "splits", name: "Splits by Atlys", iconURL: ProfileV3AppAccessFixtureLogos.splits)
        ],
        apps: [
            ProfileV3LinkedApp(
                id: "instagram",
                name: "Instagram",
                iconURL: ProfileV3AppAccessFixtureLogos.instagram,
                blurb: "Meet Ayl on Instagram\nFollow Ayl and say hi, so your agent can plan and recommend the best "
                    + "of everything for you.",
                username: nil,
                isConnected: false,
                asksForUsernameOnly: true
            ),
            app(
                "grab",
                "Grab",
                ProfileV3AppAccessFixtureLogos.grab,
                "Get around with less hassle\nMake your arrival and local travel easier\nAtlys can use supported Grab "
                    + "services to help coordinate rides, estimate transport options and organise journeys around "
                    + "your itinerary."
            ),
            app(
                "uber",
                "Uber",
                ProfileV3AppAccessFixtureLogos.uber,
                "Ride without the back and forth\nAtlys can use supported Uber services to book rides, compare "
                    + "fares and line up pickups around your itinerary."
            ),
            app(
                "stripe",
                "Stripe",
                ProfileV3AppAccessFixtureLogos.stripe,
                "Keep travel payments together\nAtlys can use supported Stripe services to track bookings and "
                    + "receipts across your trips."
            ),
            app(
                "plaid",
                "Plaid",
                ProfileV3AppAccessFixtureLogos.plaid,
                "Link your accounts securely\nAtlys can use supported Plaid services to confirm balances and "
                    + "income for your applications."
            ),
            app(
                "spotify",
                "Spotify",
                ProfileV3AppAccessFixtureLogos.spotify,
                "Bring your music along\nAtlys can use supported Spotify services to line up playlists for "
                    + "flights and long drives."
            ),
            app(
                "strava",
                "Strava",
                ProfileV3AppAccessFixtureLogos.strava,
                "Stay active on the road\nAtlys can use supported Strava services to find routes and activities "
                    + "near where you stay."
            )
        ]
    )

    private static func app(_ id: String, _ name: String, _ iconURL: URL?, _ blurb: String) -> ProfileV3LinkedApp {
        ProfileV3LinkedApp(id: id, name: name, iconURL: iconURL, blurb: blurb, username: nil, isConnected: false)
    }
}
#endif
