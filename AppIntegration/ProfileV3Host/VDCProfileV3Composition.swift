import AIProfile

@MainActor
enum VDCProfileV3Composition {
    static func configure() {
        ProfileV3EntryPoint.configure(ProfileV3Environment(
            baseProvider: VDCProfileV3BaseProvider(),
            session: VDCProfileV3Session(),
            kyc: VDCProfileV3KYCHost(),
            identityCapture: VDCProfileV3IdentityCaptureHost(),
            globe: VDCProfileV3GlobeRenderer(),
            analytics: VDCProfileV3Analytics(),
            navigation: VDCProfileV3NavigationHost(),
            validation: VDCProfileV3FieldValidator(),
            account: VDCProfileV3AccountHost(),
            coupons: VDCProfileV3CouponsHost(),
            app: VDCProfileV3AppHost(),
            countries: VDCProfileV3Countries.catalogue
        ))
    }
}
