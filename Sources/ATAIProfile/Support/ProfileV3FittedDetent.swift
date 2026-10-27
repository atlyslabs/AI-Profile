import SwiftUI

extension View {
    func profileV3FittedDetent(_ height: CGFloat?, until fallback: PresentationDetent = .medium) -> some View {
        presentationDetents(height.map { [.height($0)] } ?? [fallback])
    }
}
