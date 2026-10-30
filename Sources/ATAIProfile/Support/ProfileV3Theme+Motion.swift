import SwiftUI

extension ProfileV3Theme {
    enum Motion {
        static let ambientFrameInterval: TimeInterval = 1.0 / 24
        static let passportGlowOpacity: Double = 0.5
        static let passportStripOpacity: Double = 0.2
        static let passportGuillocheOpacity: Double = 0.05
        static let passportExpiredOpacity: Double = 0.5
        static let passportPageLabelOpacity: Double = 0.5
        static let passportBackLabelOpacity: Double = 0.3
        static let aiConnectorCopiedSeconds: Double = 1.5
        static let aiConnectorReveal: Animation = .easeInOut(duration: 0.25)
        static let instagramExplainerSeconds: Double = 3.5
        static let instagramRedirectSeconds: Double = 1.8
        static let catalogueSearchDebounceMilliseconds = 300
        static let catalogueLoaderMinimumMilliseconds = 400
        static let remoteImageFadeSeconds: Double = 0.3
        static let selection: Animation = .easeInOut(duration: 0.2)
        static let expand: Animation = .easeInOut(duration: 0.25)
        static let hero: Animation = .spring(response: 0.5, dampingFraction: 0.86)
        static let hintNudgeSeconds: Double = 1.2
        static let holdDuration: TimeInterval = 0.6
        static let heroSettleMilliseconds = 550
        static let frameDelayMilliseconds = 16
        static let contentFadeMilliseconds = 250
        static let hintDelayMilliseconds = 600
        static let contentFade: Animation = .easeOut(duration: 0.25)
        static let hintAppear: Animation = .spring(response: 0.45, dampingFraction: 0.8)
        static let flipSeconds: TimeInterval = 0.6
        static let flip: Animation = .spring(response: flipSeconds, dampingFraction: 0.82)
        static let flipDemoHoldSeconds: TimeInterval = 2
        static let pressedScale: CGFloat = 0.97
        static let savedDismissMilliseconds = 1200
        static let toastDismissMilliseconds = 3000
        static let pickupAutoLaunches = true
        static let pickupAutoLaunchMilliseconds = 1000
        static let stagedDismissMilliseconds = 2800
        static let launchDelayMilliseconds = 2000
        static let launch: Animation = .timingCurve(0.85, 0, 0.15, 1, duration: 1.3)
        static let launchFade: Animation = .easeOut(duration: 0.3)
        static let stagedCopy: Animation = .easeOut(duration: 0.4).delay(1.0)
        static let saveState: Animation = .easeInOut(duration: 0.3)
        static let entry: Animation = .spring(response: 0.45, dampingFraction: 0.85)
        static let entryScale: CGFloat = 0.9
        static let fullScreenEnterScale: CGFloat = 0.96
        static var fullScreenTransition: AnyTransition {
            .asymmetric(insertion: .opacity.combined(with: .scale(scale: fullScreenEnterScale)), removal: .opacity)
        }
        static let entryOffsetY: CGFloat = 8
        static let entryRevealMilliseconds = 450
        static let entryBreathMilliseconds = 300
        static let entryStepMilliseconds = entryRevealMilliseconds + entryBreathMilliseconds
        static let entryStaggerMilliseconds = 100
        static let pageSlideSeconds: TimeInterval = 0.4
        static let copiedResetSeconds: TimeInterval = 1.5
        static let reorderHintSeconds: TimeInterval = 0.5
        static let reorderHint: Animation = .smooth(duration: reorderHintSeconds)
        static let reorderHintDelayMilliseconds = 900
        static let passportFrontOnlyFinishMilliseconds = 600
        static let reorderDemoMoveSeconds: TimeInterval = 0.6
        static let reorderDemoHoldSeconds: TimeInterval = 0.4
        static let reorderDemoCycleSeconds = reorderDemoMoveSeconds + reorderDemoHoldSeconds
        static let reorderDemoSwaps = 2
        static let reorderDemoMove: Animation = .easeInOut(duration: reorderDemoMoveSeconds)
        static let pageSlideParallax: CGFloat = 0.3
        static let pageSlideDim: CGFloat = 0.1
        static let hoverHalfCycleSeconds: Double = 1.4
        static let hoverSettleSeconds = hoverHalfCycleSeconds
        static let hoverAmplitude: CGFloat = 4
        static let hoverShadowRaisedScale: CGFloat = 0.88
        static let hoverShadowRaisedOpacity: Double = 0.6
        static let kycGlowRiseSeconds: TimeInterval = 1.2
        static let kycGlowCaptionSeconds: TimeInterval = 0.35
        static let kycGlowHoldSeconds: TimeInterval = 2.5
        static let kycGlowFadeSeconds: TimeInterval = 0.6
        static let kycGlowSeconds = kycGlowRiseSeconds + kycGlowCaptionSeconds + kycGlowHoldSeconds + kycGlowFadeSeconds
        static let kycGlowRise: Animation = .easeInOut(duration: kycGlowRiseSeconds)
        static let kycGlowCaption: Animation = .easeOut(duration: kycGlowCaptionSeconds)
        static let kycGlowFade: Animation = .easeOut(duration: kycGlowFadeSeconds).delay(kycGlowHoldSeconds)
        static let kycRedirectMilliseconds = 1800
        static let scanMinimumMilliseconds = 3000
        static let citizenshipLockEnter = UnitCurve.bezier(
            startControlPoint: UnitPoint(x: 0.16, y: 1),
            endControlPoint: UnitPoint(x: 0.3, y: 1)
        )
        static let citizenshipLockExit = UnitCurve.bezier(
            startControlPoint: UnitPoint(x: 0.7, y: 0),
            endControlPoint: UnitPoint(x: 0.84, y: 0)
        )
        static let citizenshipLockFadeInSeconds: TimeInterval = 0.25
        static let citizenshipLockVisibleSeconds: TimeInterval = 1.6
        static let citizenshipLockFadeOutSeconds: TimeInterval = 0.15
        static let citizenshipLockRiseSeconds: TimeInterval = 0.5
        static let citizenshipLockHoldSeconds: TimeInterval = 1.0
        static let foundHoldMilliseconds = 1200
        static let scanStepMilliseconds = 600
        static let orbSpin: Animation = .linear(duration: 4).repeatForever(autoreverses: false)
        static let orbRingOpacity: Double = 0.2
        static let popInScale: CGFloat = 0.9
        static let expandEnterScale: CGFloat = 0.95
        static let kycOverlayGlowOpacity: Double = 0.2
        static let disabledOpacity: Double = 0.5
        static let collapseChromeFadeEnd: CGFloat = 0.25
        static let collapseNameFadeStart: CGFloat = 0.5
        static let collapseTabFadeStart: CGFloat = 0.85
        static let collapseInteractionLimit: CGFloat = 0.5
        static let hiddenFaceOpacity: Double = 0.01
        static let contentSwitch: Animation = .easeOut(duration: 0.35)
        static let detailEntry: Animation = .easeOut(duration: 0.45)
        static let detailEntryStagger: Double = 0.07
        static let detailEntryOffset: CGFloat = 14
        static let stackRotateSeconds = 5
        static let disconnectGraceSeconds = 5
        static let logoutAcknowledgeTimeoutSeconds = 3
        static let settingsWriteTimeoutSeconds = 8
        static let restartCoverFadeSeconds: TimeInterval = 0.2
        static let restartCoverTimeoutSeconds = 6
        static let restartCoverPollMilliseconds = 100
        static let stackRotate: Animation = .easeInOut(duration: 0.5)
        static let stackExit: Animation = .easeInOut(duration: 0.3)
        static let stackEnter: Animation = .easeInOut(duration: 0.35)
        static let stackExitOffset: CGFloat = -16
        static let contentSwitchOffset: CGFloat = 12
        static let podiumHide: Animation = .easeOut(duration: 0.15)
        static let podiumShow: Animation = entry
        static let spinner: Animation = .linear(duration: 1).repeatForever(autoreverses: false)
        static let spinnerTrim: CGFloat = 0.84
        static let spinnerFadeEnd: CGFloat = 0.35
        static let insightReveal: Animation = .easeOut(duration: 0.45)
        static let tileEntry: Animation = entry
        static let tileEntryStaggerSeconds: Double = 0.07
        static let tileEntryScale: CGFloat = 0.96
        static let tileEntryOffsetY: CGFloat = 12
        static let insightRevealOffset: CGFloat = 8
        static let insightRevealMilliseconds = 700
        static let programmeRemove: Animation = .easeInOut(duration: 0.3)
    }
}
