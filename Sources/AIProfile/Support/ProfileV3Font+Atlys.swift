import ATUIKit
import SwiftUI

extension Font {
    struct Inter {
        static func get(size: CGFloat, weight: Weight = .regular) -> Font {
            .inter(size: size, weight: AtlysFontWeight(weight))
        }
    }

    struct Denton {
        static func get(size: CGFloat, weight: Weight = .medium) -> Font {
            let atlys: AtlysFontWeight = switch weight {
            case .bold, .heavy, .black: .bold
            default: .medium
            }
            return .denton(size: size, weight: atlys)
        }
    }
}

private extension AtlysFontWeight {
    init(_ weight: Font.Weight) {
        switch weight {
        case .medium: self = .medium
        case .semibold: self = .semibold
        case .bold: self = .bold
        default: self = .regular
        }
    }
}
