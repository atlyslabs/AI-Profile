import ATUIKit
import SwiftUI

struct ProfileV3CopyButton: View {
    let isCopied: Bool
    let size: CGFloat
    let tint: Color
    let hitInset: CGFloat
    let copyLabel: String
    let copiedLabel: String
    var feedback: SensoryFeedback?
    let action: () -> Void

    var body: some View {
        styled
            .padding(-hitInset)
            .accessibilityLabel(isCopied ? copiedLabel : copyLabel)
    }

    @ViewBuilder
    private var styled: some View {
        if let feedback {
            button.buttonStyle(.profileV3Pressable(feedback))
        } else {
            button.buttonStyle(.plain)
        }
    }

    private var button: some View {
        Button(action: action) {
            (isCopied ? ATIcon.SwiftUIImage.check : ATIcon.SwiftUIImage.contentCopy)
                .profileV3Icon(size)
                .foregroundStyle(tint)
                .padding(hitInset)
                .contentShape(Rectangle())
        }
    }
}

@MainActor
struct ProfileV3CopyTimer {
    private var task: Task<Void, Never>?

    mutating func restart(_ reset: @escaping @MainActor () -> Void) {
        task?.cancel()
        task = Task { @MainActor in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.copiedResetSeconds))
            guard !Task.isCancelled else { return }
            reset()
        }
    }

    mutating func cancel() {
        task?.cancel()
        task = nil
    }
}
