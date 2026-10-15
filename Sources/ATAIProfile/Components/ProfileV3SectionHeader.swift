import ATUIKit
import SwiftUI

struct ProfileV3SectionHeader: View {
    let title: String
    var status: ProfileV3StatusDot.Kind?
    var trailing: String?
    var trailingDetail: String?
    var onTrailingTap: (() -> Void)?

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s8) {
            ProfileV3TagLabel(text: title)
            if let status {
                ProfileV3StatusDot(kind: status)
            }
            Spacer(minLength: 0)
            if let trailing {
                let label = (Text(trailing).foregroundStyle(Color(at: .pureBlack))
                    + Text(trailingDetail.map { " \($0)" } ?? "").foregroundStyle(ProfileV3Theme.Palette.secondaryText))
                    .typoGraphy(.H7InterMedium16)
                if let onTrailingTap {
                    Button(action: onTrailingTap) {
                        HStack(spacing: ProfileV3Theme.Space.s4) {
                            ProfileV3TagLabel(text: trailing)
                            ATIcon.SwiftUIImage.chevronRight
                                .profileV3Icon(ProfileV3Theme.Icon.md)
                                .foregroundStyle(Color(at: .pureBlack))
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    label
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(statusValue)
    }

    private var statusValue: String {
        switch status {
        case .complete: return ProfileV3Strings.sectionComplete
        case .pending: return ProfileV3Strings.sectionPending
        case nil: return ""
        }
    }
}

#if DEBUG
#Preview("Section headers") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3SectionHeader(title: "Airlines", status: .complete)
        ProfileV3SectionHeader(title: "Allergies", status: .pending)
        ProfileV3SectionHeader(title: "Flying hours", status: .complete, trailing: "10 hrs max")
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
