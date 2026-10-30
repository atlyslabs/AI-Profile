import ATUIKit
import SwiftUI

struct ProfileV3TermsView: View {
    let terms: ProfileV3Terms?
    var phase: ProfileV3LoadPhase = .loaded
    var onRetry: () -> Void = {}
    let onBack: () -> Void


    var body: some View {
        VStack(spacing: 0) {
            header
            if let terms {
                ProfileV3FadingScroll {
                    sections(terms)
                        .padding(.horizontal, ProfileV3Theme.Sizes.Terms.horizontalMargin)
                        .padding(.top, ProfileV3Theme.Sizes.Terms.contentTop)
                        .padding(.bottom, ProfileV3Theme.Sizes.Terms.contentBottom)
                }
            } else {
                ProfileV3LoadStateView(phase: phase, retry: onRetry)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                ATIcon.SwiftUIImage.chevronLeft
                    .profileV3Icon(ProfileV3Theme.Icon.xl)
                    .foregroundStyle(Color(at: .pureBlack))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(ProfileV3Strings.back)
            ProfileV3ConnectorGlyph.atlysWordmark.image
                .resizable()
                .scaledToFit()
                .frame(
                    width: ProfileV3Theme.Sizes.Terms.wordmarkWidth,
                    height: ProfileV3Theme.Sizes.Terms.wordmarkHeight
                )
                .padding(.top, ProfileV3Theme.Sizes.Terms.wordmarkTop)
                .accessibilityHidden(true)
            if let title = terms?.title.nonEmpty {
                Text(title)
                    .typoGraphy(.H6InterSemibold18)
                    .foregroundStyle(Color(at: .pureBlack))
                    .padding(.top, ProfileV3Theme.Sizes.Terms.titleTop)
            }
            Rectangle()
                .fill(Color(at: .borderLightLight200))
                .frame(height: ProfileV3Theme.Stroke.hairline)
                .padding(.top, ProfileV3Theme.Sizes.Terms.dividerTop)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.Terms.horizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.Terms.backTop)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(at: .pureWhite))
    }

    private func sections(_ terms: ProfileV3Terms) -> some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Terms.sectionSpacing) {
            ForEach(terms.sections) { section in
                VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Terms.blockSpacing) {
                    if !section.title.isEmpty {
                        Text(section.title)
                            .typoGraphy(.H7InterSemibold16)
                            .foregroundStyle(Color(at: .pureBlack))
                    }
                    ForEach(section.blocks) { block in
                        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Terms.paragraphSpacing) {
                            if let heading = block.heading {
                                Text(heading)
                                    .typoGraphy(.B1InterSemibold14)
                                    .foregroundStyle(Color(at: .pureBlack))
                            }
                            ForEach(Array(block.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                                Text(paragraph)
                                    .typoGraphy(.B1InterMedium14)
                                    .foregroundStyle(Color(at: .neutralGrey600))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProfileV3TermsHost: View {
    @StateObject private var viewModel: ProfileV3TermsViewModel
    let onBack: () -> Void

    init(repository: any ProfileV3SettingsRepository, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ProfileV3TermsViewModel(loadTerms: {
            try await repository.loadTerms(locale: Locale.current.language.languageCode?.identifier)
        }))
        self.onBack = onBack
    }

    var body: some View {
        ProfileV3TermsView(
            terms: viewModel.content,
            phase: viewModel.phase,
            onRetry: viewModel.load,
            onBack: onBack
        )
        .onAppear(perform: viewModel.loadIfNeeded)
    }
}

#if DEBUG
#Preview("Terms and conditions") {
    ProfileV3TermsView(terms: ProfileV3TermsContent.terms, onBack: {})
}

#Preview("Terms · loading") {
    ProfileV3TermsView(terms: nil, phase: .loading, onBack: {})
}

#Preview("Terms · failed") {
    ProfileV3TermsView(terms: nil, phase: .failed, onBack: {})
}

#Preview("Terms host") {
    ProfileV3TermsHost(repository: ProfileV3MockRepository(), onBack: {})
}
#endif
