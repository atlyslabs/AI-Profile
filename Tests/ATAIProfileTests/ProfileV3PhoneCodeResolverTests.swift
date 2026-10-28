import Testing
@testable import ATAIProfile

@Suite("Phone code resolver", .serialized)
struct ProfileV3PhoneCodeResolverTests {
    @Test func aNumberWithoutACountryCodeTakesTheHostsResidence() {
        PhoneCodeResolver.install { "ae" }
        let phone = PhoneCodeResolver.resolve(nil)
        #expect(phone.regionISO == "AE")
        #expect(phone.dialCode == "971")
    }

    @Test func aNumberWithACountryCodeKeepsItsOwnRegion() {
        PhoneCodeResolver.install { "AE" }
        let phone = PhoneCodeResolver.resolve("+14155552671")
        #expect(phone.regionISO == "US")
        #expect(phone.dialCode == "1")
        #expect(phone.digits == "4155552671")
    }

    @Test func anEmptyResidenceFallsBackPastTheHost() {
        PhoneCodeResolver.install { "  " }
        #expect(PhoneCodeResolver.defaultRegion != "")
        #expect(PhoneCodeResolver.defaultRegion.trimmingCharacters(in: .whitespaces) == PhoneCodeResolver.defaultRegion)
    }
}
