import SwiftUI

private struct ProfileV3FeedbackOnAppear: ViewModifier {
    let feedback: SensoryFeedback

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .onAppear { hasAppeared = true }
            .sensoryFeedback(feedback, trigger: hasAppeared) { _, appeared in appeared }
    }
}

extension View {
    func profileV3FeedbackOnAppear(_ feedback: SensoryFeedback) -> some View {
        modifier(ProfileV3FeedbackOnAppear(feedback: feedback))
    }
}
