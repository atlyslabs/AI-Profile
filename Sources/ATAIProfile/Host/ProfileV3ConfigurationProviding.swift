import ATCore

/// What Chat's base provider is for chat: base URL, token, residency, analytics, and who is signed in.
/// The host's configuration object conforms to this and is registered on `ProfileV3Runtime`.
public protocol ProfileV3ConfigurationProviding: ATCoreBaseProvider, ProfileV3SessionProviding {}
