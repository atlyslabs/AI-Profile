import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxBlobs: View {
    let ellipse: CGSize
    var drift: CGSize = .zero

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        GeometryReader { proxy in
            ForEach(Array(zip(Layout.blobCentres, ProfileV3Theme.GloveBox.Palette.blobs).enumerated()), id: \.offset) { _, blob in
                Ellipse()
                    .fill(blob.1)
                    .frame(width: ellipse.width, height: ellipse.height)
                    .position(
                        x: blob.0.x * proxy.size.width + drift.width,
                        y: blob.0.y * proxy.size.height + drift.height
                    )
            }
        }
        .blur(radius: Layout.blobBlur)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ProfileV3GloveBoxActionButton: View {
    let title: String
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        Button(action: action) {
            Text(title)
                .typoGraphy(.B1InterSemibold14)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(maxWidth: .infinity)
                .frame(height: Layout.actionHeight)
                .background {
                    ZStack {
                        ProfileV3GloveBoxBlobs(ellipse: Layout.actionBlob)
                        ProfileV3GloveBoxBlobs(ellipse: Layout.actionBlob)
                        ProfileV3Theme.GloveBox.Palette.actionFrost
                    }
                }
                .clipShape(Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .accessibilityLabel(title)
    }
}

#if DEBUG
#Preview("Glove box action") {
    ProfileV3GloveBoxActionButton(title: "Complete KYC") {}
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
