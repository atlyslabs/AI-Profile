import Combine
import SwiftUI

@MainActor
final class ProfileV3HeroPresenter<Item>: ObservableObject {
    @Published private(set) var item: Item?

    var isPresenting: Bool { item != nil }

    func present(_ item: Item) {
        guard self.item == nil else { return }
        self.item = item
    }

    func dismiss() {
        guard item != nil else { return }
        item = nil
    }
}

struct ProfileV3BenefitRedemption: Equatable {
    let benefitID: String
    let sequence: Int
}

extension ProfileV3HeroPresenter where Item == ProfileV3Benefit {
    func open(_ benefit: ProfileV3Benefit, onLocked: ((ProfileV3Benefit) -> Void)?) {
        if benefit.requiresKYC, let onLocked {
            onLocked(benefit)
        } else {
            present(benefit)
        }
    }

    func dismiss(after redemption: ProfileV3BenefitRedemption?) {
        guard let redemption, item?.id == redemption.benefitID else { return }
        dismiss()
    }
}
