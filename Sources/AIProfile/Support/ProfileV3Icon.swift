import SwiftUI

extension Image {
    func profileV3Icon(_ size: CGFloat) -> some View {
        renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
