import ATUIKit
import UIKit

@MainActor
enum ProfileV3EmailBodyText {
    static func attributed(
        _ body: ProfileV3EmailBody,
        showsQuoted: Bool,
        style: TypographyStyle = .H7InterMedium16,
        strongStyle: TypographyStyle = .H7InterSemibold16,
        color: UIColor
    ) -> NSAttributedString {
        let quotedColor = color.withAlphaComponent(ProfileV3Theme.GloveBox.Palette.quotedOpacity)
        let result = NSMutableAttributedString()
        func append(_ runs: [ProfileV3EmailText.Run], allQuoted: Bool) {
            for run in runs {
                var attributes = ProfileV3FlowingTextView.attributes(
                    style: run.isBold ? strongStyle : style,
                    color: allQuoted || run.isQuoted ? quotedColor : color
                )
                if run.isItalic { attributes[.obliqueness] = ProfileV3Theme.GloveBox.Layout.emailItalicSlant }
                if let link = run.link {
                    attributes[.link] = link
                    attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                }
                result.append(NSAttributedString(string: run.text, attributes: attributes))
            }
        }
        append(body.message.runs, allQuoted: false)
        if showsQuoted, let quoted = body.quoted {
            result.append(NSAttributedString(string: "\n\n", attributes: ProfileV3FlowingTextView.attributes(style: style, color: color)))
            append(quoted.runs, allQuoted: true)
        }
        return result
    }
}
