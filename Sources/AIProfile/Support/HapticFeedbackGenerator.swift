import UIKit

@MainActor
enum HapticFeedbackGenerator {
    enum HapticFeedback {
        case error, success, input, light, medium, heavy, rigid
    }

    static func generateHapticFeedback(type feedback: HapticFeedback) {
        switch feedback {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .input:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.65)
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    }
}
