import SwiftUI

extension Image {
    func profileV3Icon(_ size: CGFloat) -> some View {
        renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

struct ProfileV3ServedIcon: View {
    let url: URL?
    let fallback: Image?
    let size: CGFloat
    let tint: Color

    var body: some View {
        if let url {
            ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
                .frame(width: size, height: size)
        } else if let fallback {
            fallback
                .profileV3Icon(size)
                .foregroundStyle(tint)
        }
    }
}
