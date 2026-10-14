import QuartzCore
import SwiftUI

private struct ProfileV3CollapseEffect: GeometryEffect {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        guard progress > 0 else { return ProjectionTransform() }
        let angle = ProfileV3Theme.collapseAngleDegrees(progress) * .pi / 180
        let push = size.height * sin(angle)
        var transform = CATransform3DIdentity
        transform.m34 = -1 / cameraDistance(push: push)
        transform = CATransform3DTranslate(transform, 0, 0, -push)
        transform = CATransform3DRotate(transform, angle, 1, 0, 0)
        transform = CATransform3DTranslate(transform, -size.width / 2, 0, 0)
        transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(size.width / 2, 0, 0))
        return ProjectionTransform(transform)
    }

    private func cameraDistance(push: CGFloat) -> CGFloat {
        let camera = ProfileV3Theme.Sizes.Collapse.cameraDistance
        let blend = CGFloat(ProfileV3Theme.ramp(progress, from: ProfileV3Theme.Motion.collapseTabFadeStart, to: 1))
        guard blend > 0, push > 0 else { return camera }
        let natural = camera / (camera + push)
        let ratio = natural + (ProfileV3Theme.Sizes.Collapse.tabTopRatio - natural) * blend
        return ratio * push / (1 - ratio)
    }
}

extension View {
    func profileV3Collapse(_ progress: CGFloat) -> some View {
        modifier(ProfileV3CollapseEffect(progress: progress).ignoredByLayout())
    }
}
