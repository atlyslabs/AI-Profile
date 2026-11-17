import ATUIKit
import UIKit

@MainActor
enum ProfileV3EmailBodyText {
    static func attributed(
        _ text: ProfileV3EmailText,
        quoted: Bool = false,
        style: TypographyStyle = .H7InterMedium16,
        strongStyle: TypographyStyle = .H7InterSemibold16,
        color: UIColor
    ) -> NSAttributedString {
        let quotedColor = color.withAlphaComponent(ProfileV3Theme.GloveBox.Palette.quotedOpacity)
        let result = NSMutableAttributedString()
        for run in text.runs {
            var attributes = ProfileV3FlowingTextView.attributes(
                style: run.isBold ? strongStyle : style,
                color: quoted || run.isQuoted ? quotedColor : color
            )
            if run.isItalic { attributes[.obliqueness] = ProfileV3Theme.GloveBox.Layout.emailItalicSlant }
            if let link = run.link {
                attributes[.link] = link
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            result.append(NSAttributedString(string: run.text, attributes: attributes))
        }
        return result
    }
}
