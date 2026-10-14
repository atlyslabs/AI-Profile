import UIKit

@MainActor
final class ProfileV3PushTransition: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        ProfileV3PushAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ProfileV3PushAnimator(isPresenting: false)
    }
}

private final class ProfileV3PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        ProfileV3Theme.Motion.pageSlideSeconds
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let page = transitionContext.view(forKey: isPresenting ? .to : .from) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        let isPresenting = isPresenting
        let container = transitionContext.containerView
        let width = container.bounds.width
        let pageOffscreen = CGAffineTransform(translationX: width, y: 0)
        let behind = transitionContext.viewController(forKey: isPresenting ? .from : .to)?.view
        let behindShifted = CGAffineTransform(translationX: -width * ProfileV3Theme.Motion.pageSlideParallax, y: 0)
        let dim = UIView(frame: container.bounds)
        dim.backgroundColor = UIColor.black.withAlphaComponent(ProfileV3Theme.Motion.pageSlideDim)
        dim.isUserInteractionEnabled = false
        if isPresenting {
            if let controller = transitionContext.viewController(forKey: .to) {
                page.frame = transitionContext.finalFrame(for: controller)
            }
            container.addSubview(page)
            page.transform = pageOffscreen
            dim.alpha = 0
        } else {
            behind?.transform = behindShifted
        }
        container.insertSubview(dim, belowSubview: page)
        let finish = {
            page.transform = .identity
            behind?.transform = .identity
            dim.removeFromSuperview()
            let completed = !transitionContext.transitionWasCancelled
            if !isPresenting, completed {
                page.removeFromSuperview()
            }
            transitionContext.completeTransition(completed)
        }
        guard transitionContext.isAnimated else {
            finish()
            return
        }
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), dampingRatio: 1) {
            page.transform = isPresenting ? .identity : pageOffscreen
            behind?.transform = isPresenting ? behindShifted : .identity
            dim.alpha = isPresenting ? 1 : 0
        }
        animator.addCompletion { _ in finish() }
        animator.startAnimation()
    }
}
