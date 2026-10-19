import ATUIKit
import SwiftUI

struct ProfileV3VaultList: View {
    @ObservedObject var model: ProfileV3AppAccessModel

    private typealias Access = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        if model.vaultEntries.isEmpty {
            VStack(spacing: ProfileV3Theme.Space.s8) {
                Text(ProfileV3VaultStrings.emptyTitle)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                Text(ProfileV3VaultStrings.emptyBody)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
            }
            .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: Access.cardSpacing) {
                ForEach(model.vaultEntries) { entry in
                    Button { model.open(entry) } label: {
                        ProfileV3VaultWebsiteRow(title: entry.displayName) {
                            Text(model.badge(for: entry))
                                .typoGraphy(.H7InterSemibold16)
                                .foregroundStyle(ProfileV3Theme.Palette.accessAction)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ProfileV3VaultSitePicker: View {
    @ObservedObject var model: ProfileV3AppAccessModel
    @State private var query = ""

    private typealias Layout = ProfileV3Theme.Sizes.AppCredentials
    private typealias Access = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text(ProfileV3Strings.appCredentialsTitle)
                        .typoGraphy(.H5InterMedium20)
                        .foregroundStyle(Color(at: .pureBlack))
                        .multilineTextAlignment(.center)
                        .frame(width: Layout.titleWidth)
                        .padding(.top, Layout.titleTop)
                        .accessibilityAddTraits(.isHeader)
                    ProfileV3CredentialField(label: ProfileV3VaultStrings.website, text: $query, keyboard: .URL)
                        .padding(.top, Layout.fieldsTop)
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    VStack(spacing: Access.cardSpacing) {
                        ForEach(filtered) { site in
                            Button { model.pick(site) } label: {
                                ProfileV3VaultWebsiteRow(title: site.displayName) {
                                    EmptyView()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        Button(action: model.pickCustomSite) {
                            ProfileV3VaultWebsiteRow(
                                title: ProfileV3VaultStrings.somewhereElse,
                                icon: ATIcon.SwiftUIImage.addCircle,
                                titleColor: ProfileV3Theme.Palette.accessAction
                            ) {
                                EmptyView()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, Access.cardsTop)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, ProfileV3Theme.Sizes.Agent.backTop + ProfileV3Theme.Sizes.circleButton)
            }
            .scrollBounceBehavior(.basedOnSize)
            .overlay(alignment: .top) { header }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .presentationDetents([.large])
        .presentationCornerRadius(Layout.cornerRadius)
        .presentationDragIndicator(.hidden)
    }

    private var header: some View {
        ZStack(alignment: .top) {
            ProfileV3SheetGrabber(
                width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                color: Color(at: .neutralGrey200),
                top: ProfileV3Theme.Space.s10
            )
            HStack {
                Spacer()
                ProfileV3CircleIconButton.close { model.isPickingSite = false }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
        }
    }

    private var filtered: [ProfileV3VaultSite] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return model.sites }
        return model.sites.filter {
            $0.displayName.localizedCaseInsensitiveContains(text) || ($0.loginURL?.localizedCaseInsensitiveContains(text) == true)
        }
    }
}

private struct ProfileV3VaultWebsiteRow<Accessory: View>: View {
    let title: String
    var icon: Image = ATIcon.SwiftUIImage.globe
    var titleColor = Color(at: .pureBlack)
    @ViewBuilder var accessory: () -> Accessory

    private typealias Access = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s12) {
            icon
                .profileV3Icon(Access.cardIcon)
                .foregroundStyle(titleColor)
            Text(title)
                .typoGraphy(.H7InterMedium16)
                .foregroundStyle(titleColor)
                .lineLimit(1)
            Spacer(minLength: ProfileV3Theme.Space.s8)
            accessory()
        }
        .padding(.leading, Access.cardLeading)
        .padding(.trailing, Access.cardTrailing)
        .padding(.top, Access.cardTop)
        .frame(maxWidth: .infinity, minHeight: Access.cardHeight, alignment: .top)
        .profileV3SettingsCard(cornerRadius: Access.cardRadius)
    }
}
