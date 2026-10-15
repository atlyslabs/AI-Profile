import ATAIProfile

@MainActor
enum VDCProfileV3Composition {
    static func configure() {
        let provider = VDCProfileV3BaseProvider()
        ProfileV3Runtime.registerConfigurationProvider { provider }
        ProfileV3Runtime.registerHostActions(ProfileV3HostActions(
            account: VDCProfileV3AccountHost(),
            app: VDCProfileV3AppHost(),
            kyc: VDCProfileV3KYCHost(),
            identityCapture: VDCProfileV3IdentityCaptureHost(),
            coupons: VDCProfileV3CouponsHost(),
            analytics: VDCProfileV3Analytics(),
            globe: VDCProfileV3GlobeRenderer(),
            validation: VDCProfileV3FieldValidator(),
            countries: VDCProfileV3Countries.catalogue
        ))
    }
}
