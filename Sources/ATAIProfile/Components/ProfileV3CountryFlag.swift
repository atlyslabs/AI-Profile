import ATUIKit
import SwiftUI

struct ProfileV3CountryFlag: View {
    enum Placeholder {
        case none
        case disc(Color)
        case globe
    }

    let country: ATCountry?
    let size: CGFloat
    var placeholder = Placeholder.none

    init(country: ATCountry?, size: CGFloat, placeholder: Placeholder = .none) {
        self.country = country
        self.size = size
        self.placeholder = placeholder
    }

    init(isoCode: String?, size: CGFloat, placeholder: Placeholder = .none) {
        self.init(country: isoCode.flatMap { ATCountry(isoCode: $0) }, size: size, placeholder: placeholder)
    }

    var body: some View {
        if let country {
            ATCountryFlagView(country: country)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            switch placeholder {
            case .none:
                EmptyView()
            case .disc(let color):
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
            case .globe:
                ATIcon.SwiftUIImage.globe
                    .profileV3Icon(size)
                    .foregroundStyle(Color(at: .pureBlack))
            }
        }
    }
}

#if DEBUG
#Preview("Country flag") {
    HStack(spacing: ProfileV3Theme.Space.s12) {
        ProfileV3CountryFlag(isoCode: "IN", size: ProfileV3Theme.Icon.xl)
        ProfileV3CountryFlag(isoCode: "ZZ", size: ProfileV3Theme.Icon.xl, placeholder: .disc(Color(at: .neutralGrey200)))
        ProfileV3CountryFlag(isoCode: nil, size: ProfileV3Theme.Icon.lg, placeholder: .globe)
    }
    .padding(ProfileV3Theme.Space.s24)
    .background(Color(at: .pureWhite))
}
#endif
