import ATUIKit
import SwiftUI

struct ProfileV3TopBar<Trailing: View, Title: View>: View {
    var onBack: (() -> Void)?
    @ViewBuilder let trailing: Trailing
    @ViewBuilder let title: Title

    var body: some View {
        HStack {
            if let onBack {
                ProfileV3CircleIconButton.back(size: ProfileV3Theme.Sizes.navButton, action: onBack)
            }
            Spacer()
            trailing
        }
        .overlay { title }
        .padding(.horizontal, ProfileV3Theme.Sizes.topBarInset)
        .padding(.top, ProfileV3Theme.Sizes.topBarTop)
    }
}

extension ProfileV3TopBar where Trailing == EmptyView {
    init(onBack: @escaping () -> Void, @ViewBuilder title: () -> Title) {
        self.init(onBack: onBack, trailing: { EmptyView() }, title: title)
    }
}

extension ProfileV3TopBar where Title == EmptyView {
    init(onBack: (() -> Void)? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.init(onBack: onBack, trailing: trailing, title: { EmptyView() })
    }
}

extension View {
    func profileV3TopBarBackdrop() -> some View {
        frame(height: ProfileV3Theme.Sizes.topBarBackdropHeight, alignment: .top)
            .frame(maxWidth: .infinity)
            .background(Color(at: .pureWhite).ignoresSafeArea(edges: .top))
    }
}

struct ProfileV3CloseBar: View {
    let action: () -> Void

    var body: some View {
        ProfileV3TopBar(trailing: {
            ProfileV3CircleIconButton.close(size: ProfileV3Theme.Sizes.navButton, action: action)
        })
    }
}

#if DEBUG
#Preview("Close bar") {
    VStack {
        ProfileV3CloseBar {}
        Spacer()
    }
    .background(Color(at: .pureWhite))
}
#endif
