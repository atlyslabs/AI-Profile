import ATUIKit
import SwiftUI

struct ProfileV3SheetMetrics: Equatable {
    var destinationHeights: [ProfileV3SettingsDestination: CGFloat] = [:]

    func height(
        for destination: ProfileV3SettingsDestination,
        maxHeight: CGFloat,
        bottomInset: CGFloat
    ) -> CGFloat {
        guard !destination.isFullHeight else { return maxHeight }
        return clamped(destinationHeights[destination] ?? 0, maxHeight: maxHeight, bottomInset: bottomInset)
    }

    private func clamped(_ measured: CGFloat, maxHeight: CGFloat, bottomInset: CGFloat) -> CGFloat {
        guard measured > 0 else { return maxHeight }
        return min(measured + bottomInset, maxHeight)
    }
}

struct ProfileV3DestinationHeightReporter: ViewModifier {
    @Binding var height: CGFloat?

    @State private var measurement = ProfileV3HeightMeasurement()

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measurement.content = $0 }
            .frame(maxHeight: .infinity, alignment: .top)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measurement.available = $0 }
            .background(Color(at: .pureWhite))
            .onChange(of: measurement) { _, measured in record(measured) }
    }

    private func record(_ measured: ProfileV3HeightMeasurement) {
        guard measured.content > 0, measured.available > 0 else { return }
        let fillsAvailable = measured.content >= measured.available - ProfileV3Theme.Sizes.sheetMeasureTolerance
        guard height == nil || !fillsAvailable else {
            if let height, height < measured.available {
                self.height = measured.available
            }
            return
        }
        height = measured.content
    }
}

private struct ProfileV3HeightMeasurement: Equatable {
    var content: CGFloat = 0
    var available: CGFloat = 0
}
