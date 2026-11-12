import Foundation
import Testing
@testable import ATAIProfile

@Suite("Vault device")
struct ProfileV3VaultDeviceTests {
    @Test func onlyAnUnenrolledDeviceEnrollsAgain() {
        #expect(ProfileV3VaultClient.isDeviceNotEnrolled(ProfileV3Error.server(code: nil, message: "device not enrolled")))
        #expect(ProfileV3VaultClient.isDeviceNotEnrolled(ProfileV3Error.server(code: nil, message: "Device not enrolled")))
        #expect(!ProfileV3VaultClient.isDeviceNotEnrolled(ProfileV3Error.server(code: nil, message: "signature rejected")))
        #expect(!ProfileV3VaultClient.isDeviceNotEnrolled(ProfileV3Error.server(code: nil, message: "credential not found")))
        #expect(!ProfileV3VaultClient.isDeviceNotEnrolled(ProfileV3Error.unauthorized))
        #expect(!ProfileV3VaultClient.isDeviceNotEnrolled(CancellationError()))
    }
}
