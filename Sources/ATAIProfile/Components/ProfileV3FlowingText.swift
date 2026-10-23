import ATUIKit
import SwiftUI
import UIKit

struct ProfileV3FlowingText: UIViewRepresentable {
    let text: String
    var style: TypographyStyle = .H7InterMedium16
    var color: Color = Color(at: .pureBlack)
    var trailingExclusion: CGSize = .zero
    var besideWidth: CGFloat?

    func makeUIView(context: Context) -> ProfileV3FlowingTextView {
        ProfileV3FlowingTextView()
    }

    func updateUIView(_ view: ProfileV3FlowingTextView, context: Context) {
        view.configure(text: text, style: style, color: UIColor(color), exclusion: trailingExclusion, besideWidth: besideWidth)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView view: ProfileV3FlowingTextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width.isFinite, width > 0 else { return nil }
        return CGSize(width: width, height: view.fittingHeight(for: width))
    }
}

final class ProfileV3FlowingTextView: UITextView {
    private var exclusion: CGSize = .zero
    private var besideWidth: CGFloat?
    private var excludedWidth: CGFloat?

    init() {
        super.init(frame: .zero, textContainer: nil)
        isEditable = false
        isSelectable = false
        isScrollEnabled = false
        backgroundColor = .clear
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(text: String, style: TypographyStyle, color: UIColor, exclusion: CGSize, besideWidth: CGFloat? = nil) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = style.lineSpacingAdjustment
        let attributed = NSAttributedString(
            string: text,
            attributes: [
                .font: style.uiFont,
                .tracking: style.trackingPoints,
                .paragraphStyle: paragraph,
                .foregroundColor: color,
            ]
        )
        if attributedText != attributed { attributedText = attributed }
        guard self.exclusion != exclusion || self.besideWidth != besideWidth else { return }
        self.exclusion = exclusion
        self.besideWidth = besideWidth
        excludedWidth = nil
        setNeedsLayout()
    }

    func fittingHeight(for width: CGFloat) -> CGFloat {
        exclude(at: width)
        let fitted = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return max(ceil(fitted.height), exclusion.height)
    }

    override func layoutSubviews() {
        exclude(at: bounds.width)
        super.layoutSubviews()
    }

    private func exclude(at width: CGFloat) {
        guard width > 0, excludedWidth != width else { return }
        excludedWidth = width
        guard exclusion.width > 0, exclusion.height > 0 else {
            textContainer.exclusionPaths = []
            return
        }
        let reserved = min(max(exclusion.width, besideWidth.map { width - $0 } ?? 0), width)
        let corner = CGRect(x: width - reserved, y: 0, width: reserved, height: exclusion.height)
        textContainer.exclusionPaths = [UIBezierPath(rect: corner)]
    }
}
