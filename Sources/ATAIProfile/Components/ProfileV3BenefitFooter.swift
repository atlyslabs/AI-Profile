import ATUIKit
import SwiftUI

struct ProfileV3BenefitFooter: View {
    let status: ProfileV3Benefit.Status

    var body: some View {
        switch status {
        case .locked:
            ProfileV3ActivatePill()
        case .active(let validTill):
            if !validTill.isEmpty {
                caption(validTill)
            }
        case .partiallyRedeemed(let usage, let validTill, _):
            ProfileV3UsageCaption(usedLabel: usage, validLabel: validTill)
        case .redeemed(let on):
            if !on.isEmpty {
                caption(on)
            }
        }
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .typoGraphy(.B2InterMedium12)
            .foregroundStyle(Color(at: .neutralGrey400))
    }
}
