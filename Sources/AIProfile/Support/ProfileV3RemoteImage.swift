import ATUIKit
import Nuke
import SwiftUI
import UIKit

struct ProfileV3RemoteImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var placeholder: Color = ProfileV3Theme.Palette.imagePlaceholder
    var showsLoader = false
    var rotatesLandscapeToPortrait = false
    var onLoad: ((UIImage) -> Void)?

    @State private var image: UIImage?
    @State private var isLoading = false

    private static let fade = AnyTransition.opacity.animation(
        .easeInOut(duration: ProfileV3Theme.Motion.remoteImageFadeSeconds)
    )

    var body: some View {
        ZStack {
            placeholder
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(Self.fade)
            } else if showsLoader && isLoading {
                ProfileV3Spinner()
                    .transition(Self.fade)
            }
        }
        .task(id: url) { await load() }
    }

    @MainActor
    private func load() async {
        image = nil
        guard let url else {
            isLoading = false
            return
        }
        if let cached = Self.cached(url) {
            show(prepared(cached))
            isLoading = false
            return
        }
        isLoading = true
        let loaded = await Self.fetch(url)
        guard !Task.isCancelled else {
            isLoading = false
            return
        }
        show(prepared(loaded))
        isLoading = false
    }

    private func show(_ loaded: UIImage?) {
        image = loaded
        if let loaded { onLoad?(loaded) }
    }

    @MainActor
    static func image(at url: URL) async -> UIImage? {
        if let cached = cached(url) {
            return cached
        }
        return await fetch(url)
    }

    private func prepared(_ image: UIImage?) -> UIImage? {
        guard let image else { return nil }
        guard rotatesLandscapeToPortrait, image.size.width > image.size.height else { return image }
        return image.profileV3RotatedCounterClockwise()
    }

    private static func cached(_ url: URL) -> UIImage? {
        ImagePipeline.shared.cache.cachedImage(for: ImageRequest(url: url))?.image
    }

    nonisolated private static func fetch(_ url: URL) async -> UIImage? {
        try? await ImagePipeline.shared.image(for: url)
    }
}

private extension UIImage {
    func profileV3RotatedCounterClockwise() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let bounds = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        return UIGraphicsImageRenderer(bounds: bounds, format: format).image { renderer in
            renderer.cgContext.translateBy(x: 0, y: size.width)
            renderer.cgContext.rotate(by: -.pi / 2)
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
