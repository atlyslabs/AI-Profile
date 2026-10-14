import CoreHaptics
import UIKit

@MainActor
final class ProfileV3ConnectorHaptics {

    static let shared = ProfileV3ConnectorHaptics()

    private static let gain: Float = 1.75

    private enum Drag {
        static let detents = 7
        static let span: TimeInterval = 30
        static let restIntensity: Float = 0.08
        static let peakIntensity: Float = 0.55
        static let restSharpness: Float = 0.1
        static let peakSharpness: Float = 0.45
        static let tickBaseIntensity: Float = 0.2
        static let tickIntensityGain: Float = 0.3
        static let tickBaseSharpness: Float = 0.3
        static let tickSharpnessGain: Float = 0.35
        static let armIntensity: Float = 0.85
        static let armSharpness: Float = 0.8
    }

    private var engine: CHHapticEngine?
    private var dragPlayer: CHHapticAdvancedPatternPlayer?
    private var lastDetent = -1
    private var isArmed = false

    private init() {}

    // MARK: - Drag

    func beginDrag() {
        lastDetent = -1
        isArmed = false
        stopDragPlayer()
        guard supportsHaptics else { return }
        do {
            let engine = try startedEngine()
            let pattern = try CHHapticPattern(
                events: [
                    continuous(at: 0, duration: Drag.span, intensity: 1, sharpness: 1)
                ],
                parameterCurves: []
            )
            let player = try engine.makeAdvancedPlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            dragPlayer = player
            sendDragParameters(for: 0)
        } catch {
            dragPlayer = nil
        }
    }

    func updateDrag(progress: Double) {
        let clamped = Float(min(max(progress, 0), 1))
        sendDragParameters(for: clamped)

        let detent = min(Int(clamped * Float(Drag.detents)), Drag.detents)
        if detent > lastDetent {
            lastDetent = detent
            if detent > 0, progress < 1 {
                tick(
                    intensity: Drag.tickBaseIntensity + Drag.tickIntensityGain * clamped,
                    sharpness: Drag.tickBaseSharpness + Drag.tickSharpnessGain * clamped
                )
            }
        } else if detent < lastDetent {
            lastDetent = detent
        }

        if progress >= 1, !isArmed {
            isArmed = true
            play(
                events: [transient(at: 0, intensity: Drag.armIntensity, sharpness: Drag.armSharpness)],
                fallback: .rigid
            )
        } else if progress < 1, isArmed {
            isArmed = false
        }
    }

    func cancelDrag() {
        stopDragPlayer()
        lastDetent = -1
        isArmed = false
        play(
            events: [continuous(at: 0, duration: 0.18, intensity: 0.22, sharpness: 0.15)],
            curves: [intensityRamp(from: 0.3, to: 0, start: 0, duration: 0.18)],
            fallback: .light
        )
    }

    // MARK: - Release cinematic

    func absorb() {
        stopDragPlayer()
        lastDetent = -1
        isArmed = false
        let rise = ProfileV3Theme.Motion.connectorDeckRiseDuration
        play(
            events: [
                transient(at: 0, intensity: 1, sharpness: 0.65),
                continuous(at: 0.06, duration: 0.3, intensity: 0.4, sharpness: 0.2),
                continuous(at: 0.4, duration: rise - 0.4, intensity: 0.28, sharpness: 0.12),
                transient(at: rise - 0.05, intensity: 0.5, sharpness: 0.4)
            ],
            curves: [intensityRamp(from: 0.15, to: 0.45, start: 0.4, duration: rise - 0.4)],
            fallback: .heavy
        )
    }

    func submerge() {
        let duration = ProfileV3Theme.Motion.connectorDeckSubmergeDuration
        play(
            events: [continuous(at: 0, duration: duration, intensity: 0.35, sharpness: 0.1)],
            curves: [intensityRamp(from: 0.5, to: 0.08, start: 0, duration: duration)],
            fallback: .medium
        )
    }

    func emerge() {
        let duration = ProfileV3Theme.Motion.connectorDeckEmergeDuration
        play(
            events: [
                continuous(at: 0, duration: duration, intensity: 0.4, sharpness: 0.25),
                transient(at: duration - 0.04, intensity: 0.55, sharpness: 0.5)
            ],
            curves: [intensityRamp(from: 0.1, to: 0.6, start: 0, duration: duration)],
            fallback: .medium
        )
    }

    func dim() {
        let duration = ProfileV3Theme.Motion.connectorDeckDimDuration
        play(
            events: [continuous(at: 0, duration: duration, intensity: 0.18, sharpness: 0.08)],
            curves: [intensityRamp(from: 0.28, to: 0.04, start: 0, duration: duration)],
            fallback: .light
        )
    }

    func pair() {
        let duration = ProfileV3Theme.Motion.connectorDeckSlideDuration
        play(
            events: [
                continuous(at: 0, duration: duration - 0.08, intensity: 0.3, sharpness: 0.3),
                transient(at: duration - 0.06, intensity: 1, sharpness: 0.9),
                transient(at: duration + 0.02, intensity: 0.45, sharpness: 0.5)
            ],
            curves: [intensityRamp(from: 0.12, to: 0.5, start: 0, duration: duration - 0.08)],
            fallback: .success
        )
    }

    // MARK: - Drag playback

    private func sendDragParameters(for progress: Float) {
        guard let dragPlayer else { return }
        let intensity = Self.scaled(Drag.restIntensity + (Drag.peakIntensity - Drag.restIntensity) * progress)
        let sharpness = Drag.restSharpness + (Drag.peakSharpness - Drag.restSharpness) * progress
        try? dragPlayer.sendParameters(
            [
                CHHapticDynamicParameter(
                    parameterID: .hapticIntensityControl,
                    value: intensity,
                    relativeTime: 0
                ),
                CHHapticDynamicParameter(
                    parameterID: .hapticSharpnessControl,
                    value: sharpness,
                    relativeTime: 0
                )
            ],
            atTime: CHHapticTimeImmediate
        )
    }

    private func stopDragPlayer() {
        try? dragPlayer?.stop(atTime: CHHapticTimeImmediate)
        dragPlayer = nil
    }

    private func tick(intensity: Float, sharpness: Float) {
        play(
            events: [transient(at: 0, intensity: intensity, sharpness: sharpness)],
            fallback: .input
        )
    }

    // MARK: - Pattern building

    private static func scaled(_ intensity: Float) -> Float {
        min(max(intensity * gain, 0), 1)
    }

    private func transient(at time: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: Self.scaled(intensity)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: time
        )
    }

    private func continuous(
        at time: TimeInterval,
        duration: TimeInterval,
        intensity: Float,
        sharpness: Float
    ) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: Self.scaled(intensity)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: time,
            duration: duration
        )
    }

    private func intensityRamp(
        from start: Float,
        to end: Float,
        start startTime: TimeInterval,
        duration: TimeInterval
    ) -> CHHapticParameterCurve {
        CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0, value: start),
                .init(relativeTime: duration, value: end)
            ],
            relativeTime: startTime
        )
    }

    // MARK: - Playback

    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    private func play(
        events: [CHHapticEvent],
        curves: [CHHapticParameterCurve] = [],
        fallback: HapticFeedbackGenerator.HapticFeedback
    ) {
        guard supportsHaptics else {
            HapticFeedbackGenerator.generateHapticFeedback(type: fallback)
            return
        }
        do {
            let engine = try startedEngine()
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            HapticFeedbackGenerator.generateHapticFeedback(type: fallback)
        }
    }

    private func startedEngine() throws -> CHHapticEngine {
        if let engine {
            try engine.start()
            return engine
        }
        let engine = try CHHapticEngine()
        engine.isAutoShutdownEnabled = true
        engine.resetHandler = { [weak engine] in try? engine?.start() }
        engine.stoppedHandler = { _ in }
        try engine.start()
        self.engine = engine
        return engine
    }
}
