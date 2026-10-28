import ATUIKit
import SwiftUI
import UIKit

private final class ProfileV3WindowBox {
    weak var window: UIWindow?
}

private final class ProfileV3WindowReaderView: UIView {
    var box: ProfileV3WindowBox?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        box?.window = window
    }
}

private struct ProfileV3WindowReader: UIViewRepresentable {
    let box: ProfileV3WindowBox

    func makeUIView(context: Context) -> ProfileV3WindowReaderView {
        let view = ProfileV3WindowReaderView()
        view.isUserInteractionEnabled = false
        view.box = box
        return view
    }

    func updateUIView(_ uiView: ProfileV3WindowReaderView, context: Context) {
        uiView.box = box
        box.window = uiView.window
    }
}

private struct ProfileV3KeyboardLift: ViewModifier {
    let bottomInset: CGFloat
    let clearance: CGFloat

    @State private var keyboardHeight: CGFloat = 0
    @State private var windowBox = ProfileV3WindowBox()

    func body(content: Content) -> some View {
        content
            .background(ProfileV3WindowReader(box: windowBox))
            .padding(.bottom, max(bottomInset, keyboardHeight - clearance))
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) {
                update(with: $0)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) {
                update(with: $0, isHiding: true)
            }
    }

    private func update(with notification: Notification, isHiding: Bool = false) {
        let info = notification.userInfo
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let frame = info?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let height = isHiding ? 0 : frame.map(overlap(of:)) ?? 0
        guard abs(height - keyboardHeight) > 0.5 else { return }
        withAnimation(.easeOut(duration: duration)) {
            keyboardHeight = height
        }
    }

    private func overlap(of keyboardFrame: CGRect) -> CGFloat {
        guard let window = windowBox.window ?? ProfileV3SheetWindow.keyWindow() else { return keyboardFrame.height }
        let frame = window.convert(keyboardFrame, from: nil)
        return max(0, window.bounds.maxY - frame.minY)
    }
}

extension View {
    func profileV3KeyboardLift(bottomInset: CGFloat = 0, clearance: CGFloat = 0) -> some View {
        modifier(ProfileV3KeyboardLift(bottomInset: bottomInset, clearance: clearance))
    }

    func profileV3TapToDismissKeyboard() -> some View {
        background(ProfileV3KeyboardDismissAnchor())
    }
}

private struct ProfileV3KeyboardDismissAnchor: UIViewRepresentable {
    func makeUIView(context: Context) -> ProfileV3KeyboardDismissView {
        ProfileV3KeyboardDismissView()
    }

    func updateUIView(_ uiView: ProfileV3KeyboardDismissView, context: Context) {}
}

private final class ProfileV3KeyboardDismissView: UIView, UIGestureRecognizerDelegate {
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delaysTouchesEnded = false
        tap.isEnabled = false
        tap.delegate = self
        return tap
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        tap.view?.removeGestureRecognizer(tap)
        window?.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow() {
        tap.isEnabled = true
    }

    @objc private func keyboardWillHide() {
        tap.isEnabled = false
    }

    @objc private func dismissKeyboard() {
        window?.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while let current = view {
            if current is UITextInput { return false }
            view = current.superview
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

struct ProfileV3FocusScroll<ID: Hashable, Content: View>: View {
    let focused: ID?
    var fillsViewport = false
    var scrollComponent: ScrollComponent?
    @ViewBuilder let content: () -> Content

    @State private var viewportHeight: CGFloat = 0
    @State private var headerPin = ProfileV3HeaderPin()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                content()
                    .frame(minHeight: fillsViewport ? viewportHeight : nil, alignment: .top)
                    .profileV3HeaderFadeAnchor(headerPin)
            }
            .profileV3HeaderFade(headerPin)
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .trackScroll(ifNamed: scrollComponent)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { viewportHeight = $0 }
            .onChange(of: focused) { _, id in reveal(id, with: proxy) }
            .onChange(of: viewportHeight) { _, _ in reveal(focused, with: proxy) }
        }
    }

    private func reveal(_ id: ID?, with proxy: ScrollViewProxy) {
        guard let id else { return }
        withAnimation(ProfileV3Theme.Motion.contentFade) {
            proxy.scrollTo(id)
        }
    }
}

extension ProfileV3FocusScroll where ID == Never {
    init(
        fillsViewport: Bool = false,
        scrollComponent: ScrollComponent? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(focused: nil, fillsViewport: fillsViewport, scrollComponent: scrollComponent, content: content)
    }
}
