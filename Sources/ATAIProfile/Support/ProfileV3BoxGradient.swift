import SwiftUI

struct ProfileV3BoxGradient {
    let stops: [Gradient.Stop]
    let atOrigin: CGFloat
    let perWidth: CGFloat
    let perHeight: CGFloat

    func shading(in box: CGRect) -> GraphicsContext.Shading {
        guard box.width > 0, box.height > 0 else { return .color(.clear) }
        let slope = CGVector(dx: perWidth / box.width, dy: perHeight / box.height)
        let lengthSquared = slope.dx * slope.dx + slope.dy * slope.dy
        guard lengthSquared > 0 else { return .color(.clear) }
        let step = CGVector(dx: slope.dx / lengthSquared, dy: slope.dy / lengthSquared)
        let start = CGPoint(x: box.minX - atOrigin * step.dx, y: box.minY - atOrigin * step.dy)
        return .linearGradient(
            Gradient(stops: stops),
            startPoint: start,
            endPoint: CGPoint(x: start.x + step.dx, y: start.y + step.dy)
        )
    }
}

struct ProfileV3BoxGradientCard: View {
    let gradient: ProfileV3BoxGradient
    let cornerRadius: CGFloat

    var body: some View {
        Canvas { context, size in
            let box = CGRect(origin: .zero, size: size)
            context.fill(
                Path(roundedRect: box, cornerRadius: cornerRadius, style: .continuous),
                with: gradient.shading(in: box)
            )
        }
        .accessibilityHidden(true)
    }
}
