import ATUIKit
import SwiftUI

struct ProfileV3CredentialStoreCard: View {
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.CredentialStore

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.cardBlurbTop) {
                Text(ProfileV3Strings.credentialStore)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureWhite))
                Text(ProfileV3Strings.credentialStoreBlurb)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.credentialCardBlurb))
                    .frame(width: Layout.cardBlurbWidth, alignment: .leading)
            }
            .multilineTextAlignment(.leading)
            .padding(.leading, Layout.cardTextLeading)
            .padding(.top, Layout.cardTitleTop)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(height: Layout.cardHeight, alignment: .top)
            .background { art }
            .background(ProfileV3Theme.credentialCardGradient)
            .overlay { bottomEdge }
            .clipShape(shape)
            .contentShape(shape)
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(ProfileV3Strings.credentialStore)
        .accessibilityHint(ProfileV3Strings.credentialStoreBlurb)
    }

    private var art: some View {
        ProfileV3ConnectorGlyph.credentialCardArt.image
            .resizable()
            .frame(width: Layout.cardArt.width, height: Layout.cardArt.height)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: Layout.cardArtFade / Layout.cardArt.width),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .mask { shape.offset(y: -Layout.cardInsetShadow) }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var bottomEdge: some View {
        shape
            .fill(Color.black.opacity(ProfileV3Theme.Opacity.credentialCardInsetShadow))
            .mask {
                ZStack {
                    shape
                    shape
                        .offset(y: -Layout.cardInsetShadow)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
            }
            .allowsHitTesting(false)
    }
}

struct ProfileV3CredentialLock: View {
    let size: CGSize
    let box: CGSize

    var body: some View {
        ProfileV3ConnectorGlyph.vaultLock.image
            .resizable()
            .frame(width: size.width, height: size.height)
            .rotationEffect(.degrees(ProfileV3Theme.Sizes.CredentialStore.lockRotation))
            .frame(width: box.width, height: box.height)
            .accessibilityHidden(true)
    }
}

struct ProfileV3CredentialStoreSheet: View {
    @ObservedObject var model: ProfileV3CredentialStoreModel
    var scrolls = true
    @State private var measured = Measured()

    private struct Measured: Equatable {
        var content: CGFloat = 0
        var bar: CGFloat = 0
    }

    private typealias Layout = ProfileV3Theme.Sizes.CredentialStore
    private typealias Credentials = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if scrolls {
                    ScrollView(showsIndicators: false) {
                        measuredContent
                    }
                    .scrollBounceBehavior(.basedOnSize)
                } else {
                    measuredContent
                }
            }
            .overlay(alignment: .top) { header }
            bar
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measured.bar = $0 }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .profileV3Sheet(.fitted(fittedHeight, until: .large))
        .sheet(item: route) { route in
            switch route {
            case .picker:
                ProfileV3VaultSitePicker(model: model)
            case .editor(let editor):
                ProfileV3AppCredentialsView(viewModel: editor, onClose: model.closeSheet)
            case .deleteConfirm(let editor):
                ProfileV3DeleteLoginSheet(viewModel: editor)
            }
        }
        .sensoryFeedback(.success, trigger: model.deleteCompletions)
    }

    private var fittedHeight: CGFloat? {
        guard measured.content > 0, measured.bar > 0 else { return nil }
        return measured.content + measured.bar
    }

    private var measuredContent: some View {
        content
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measured.content = $0 }
    }

    private var route: Binding<ProfileV3CredentialStoreModel.Sheet?> {
        Binding(get: { model.sheet }, set: { if $0 == nil { model.closeSheet() } })
    }

    private var header: some View {
        ProfileV3VaultSheetHeader { model.isPresented = false }
    }

    private var content: some View {
        VStack(spacing: 0) {
            ProfileV3ShieldHeading(title: ProfileV3Strings.credentialStore) {
                ProfileV3CredentialStoreShield()
            }
            Text(ProfileV3Strings.credentialStoreSubtitle)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.appCredentialsNote))
                .multilineTextAlignment(.center)
                .frame(width: Credentials.noteWidth)
                .padding(.top, Layout.subtitleTop)
            list
                .padding(.top, Layout.rowsTop)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ProfileV3Theme.Sizes.Agent.backTop + Credentials.shieldTop)
        .padding(.bottom, Layout.listBottom)
    }

    @ViewBuilder
    private var list: some View {
        if model.entries != nil {
            VStack(spacing: Layout.rowSpacing) {
                ForEach(model.rows) { entry in
                    ProfileV3CredentialStoreRow(
                        title: entry.displayName,
                        isOpening: model.openingID == entry.id
                    ) {
                        model.open(entry)
                    }
                    .disabled(model.openingID != nil)
                }
            }
        } else {
            ProfileV3LoadStateView(phase: model.phase, retry: model.load)
                .frame(height: Layout.rowHeight)
        }
    }

    private var bar: some View {
        ProfileV3ContinueButton(title: ProfileV3Strings.credentialStoreAdd, action: model.tapAdd)
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Credentials.barTop)
            .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
    }
}

private struct ProfileV3CredentialStoreShield: View {
    private typealias Layout = ProfileV3Theme.Sizes.CredentialStore
    private typealias Credentials = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        ZStack(alignment: .topLeading) {
            ProfileV3ShieldShape()
                .fill(ProfileV3Theme.credentialShieldGradient)
                .opacity(ProfileV3Theme.Opacity.credentialSheetShield)
            ProfileV3CredentialLock(size: Layout.lock, box: Layout.lockBox)
                .offset(x: Layout.lockOffset.width, y: Layout.lockOffset.height)
        }
        .frame(width: Credentials.shield.width, height: Credentials.shield.height, alignment: .topLeading)
        .accessibilityHidden(true)
    }
}

struct ProfileV3VaultSitePicker: View {
    @ObservedObject var model: ProfileV3CredentialStoreModel
    var scrolls = true
    @State private var query = ""

    private typealias Layout = ProfileV3Theme.Sizes.CredentialStore
    private typealias Credentials = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3VaultSheetHeader(title: ProfileV3Strings.appCredentialsTitle, onClose: model.closeSheet)
            if scrolls {
                ProfileV3FadingScroll {
                    content
                }
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .profileV3Sheet(.large)
    }

    private var content: some View {
        VStack(spacing: 0) {
            ProfileV3CredentialField(
                label: ProfileV3Strings.appCredentialsWebsite,
                text: $query,
                keyboard: .URL,
                contentType: .URL
            )
            VStack(spacing: Layout.rowSpacing) {
                if model.sites == nil, model.sitesPhase == .loading {
                    ProfileV3Spinner(size: ProfileV3Theme.Icon.xl, lineWidth: ProfileV3Theme.Stroke.regular)
                        .frame(height: Layout.rowHeight)
                }
                ForEach(model.sites(matching: query)) { site in
                    ProfileV3CredentialStoreRow(title: site.displayName) { model.pick(site) }
                }
                ProfileV3CredentialStoreRow(
                    title: ProfileV3Strings.credentialOtherWebsite,
                    icon: ATIcon.SwiftUIImage.addCircle
                ) {
                    model.pickOtherWebsite(query)
                }
            }
            .padding(.top, Layout.pickerRowsTop)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, Layout.pickerSearchTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
    }
}

private struct ProfileV3VaultSheetHeader: View {
    var title: String?
    let onClose: () -> Void

    var body: some View {
        ProfileV3AgentSheetChrome(control: .close(onClose), title: {
            if let title {
                Text(title)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: ProfileV3Theme.Sizes.AppCredentials.titleWidth)
                    .accessibilityAddTraits(.isHeader)
            }
        })
    }
}

private struct ProfileV3CredentialStoreRow: View {
    let title: String
    var icon: Image = ATIcon.SwiftUIImage.language
    var isOpening = false
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.CredentialStore

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.rowTextGap) {
                icon
                    .profileV3Icon(Layout.rowIcon)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.credentialDeleteSubject))
                Text(title)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                    .lineLimit(1)
                Spacer(minLength: ProfileV3Theme.Space.s8)
                if isOpening {
                    ProfileV3Spinner(size: ProfileV3Theme.Icon.xl, lineWidth: ProfileV3Theme.Stroke.regular)
                } else {
                    ATIcon.SwiftUIImage.chevronRight
                        .profileV3Icon(ProfileV3Theme.Icon.xl)
                        .foregroundStyle(Color(at: .neutralGrey800))
                }
            }
            .padding(.leading, Layout.rowLeading)
            .padding(.trailing, Layout.rowTrailing)
            .frame(maxWidth: .infinity, minHeight: Layout.rowHeight)
            .profileV3SettingsCard(cornerRadius: Layout.rowRadius)
            .contentShape(RoundedRectangle(cornerRadius: Layout.rowRadius, style: .continuous))
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(title)
    }
}

extension View {
    func profileV3CredentialStore(_ model: ProfileV3CredentialStoreModel) -> some View {
        modifier(ProfileV3CredentialStorePresenter(model: model))
    }
}

private struct ProfileV3CredentialStorePresenter: ViewModifier {
    @ObservedObject var model: ProfileV3CredentialStoreModel

    func body(content: Content) -> some View {
        content.sheet(isPresented: $model.isPresented, onDismiss: model.cancelReads) {
            ProfileV3CredentialStoreSheet(model: model)
        }
    }
}

#if DEBUG
#Preview("Credential store card") {
    ProfileV3CredentialStoreCard {}
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
}

#Preview("Credential store") {
    let model = ProfileV3CredentialStoreModel(repository: ProfileV3MockRepository(delay: .milliseconds(200)))
    return Color(at: .neutralGrey600)
        .ignoresSafeArea()
        .profileV3CredentialStore(model)
        .task { model.open() }
}
#endif
